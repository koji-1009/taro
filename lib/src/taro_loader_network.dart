import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:taro/src/network/http_client.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_resizer.dart';
import 'package:taro/src/taro_type.dart';

/// [TaroHttpResponse] is a class that holds the necessary response information.
typedef TaroHttpResponse = ({
  int statusCode,
  Uint8List bodyBytes,
  String? reasonPhrase,
  int? contentLength,
  Map<String, String> headers,
  bool isRedirect,
});

/// [TaroHttpClient] is an interface class for GET requests to the specified URL.
abstract interface class TaroHttpClient {
  /// Creates a [TaroHttpClient].
  const TaroHttpClient();

  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  });
}

/// [TaroLoaderNetwork] is a class that manages the loading of data from a network source.
/// It uses the http package to send GET requests to the provided URL.
class TaroLoaderNetwork {
  /// Creates a [TaroLoaderNetwork].
  const TaroLoaderNetwork({
    this.resizer = const TaroResizer(),
    this.client = const HttpClient(),
  });

  factory TaroLoaderNetwork.timeout({
    required Duration timeout,
  }) =>
      TaroLoaderNetwork(
        client: HttpClient(
          timeout: timeout,
        ),
      );

  /// The [TaroResizer] instance used to resize the image.
  final TaroResizer resizer;

  /// The [TaroHttpClient] instance used to send GET requests.
  final TaroHttpClient client;

  /// Loads the data from the provided URL with the given request headers.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<({Uint8List bytes, String contentType, DateTime? expireAt})?> load({
    required String url,
    required Map<String, String> headers,
    required TaroResizeOption resizeOption,
    required TaroHeaderOption headerOption,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasHttpScheme) {
      throw TaroUriParseException(
        url: url,
      );
    }

    final TaroHttpResponse response;
    try {
      response = await client.get(
        uri: uri,
        headers: headers,
      );
    } on Exception catch (error) {
      throw TaroNetworkException(
        url: url,
        error: error,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 400) {
      // statusCode is not in the range of 200 to 399
      throw TaroHttpResponseException(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        contentLength: response.contentLength,
        headers: response.headers,
        isRedirect: response.isRedirect,
      );
    }

    if (response.bodyBytes.isEmpty) {
      // bodyBytes is empty
      throw TaroEmptyResponseException(
        url: url,
      );
    }

    DateTime? expireAt;
    // Check if custom cache duration is provided
    if (headerOption.customCacheDuration != null) {
      final now = clock.now();
      expireAt = now.add(headerOption.customCacheDuration!);
    } else if (headerOption.checkMaxAgeIfExist) {
      final cacheControl = response.headers['cache-control'] ?? '';
      final headerAge = response.headers['age'] ?? '';
      try {
        if (cacheControl.isNotEmpty) {
          final maxAge = _getMaxAge(cacheControl);
          if (maxAge == null && cacheControl.contains('max-age=')) {
            // max-age directive exists but couldn't be parsed
            throw FormatException(
                'Invalid max-age value in cache-control header');
          }
          final age = int.tryParse(headerAge) ?? 0;
          if (maxAge != null) {
            final now = clock.now();
            expireAt = now.add(Duration(seconds: maxAge - age));
          }
        }
      } on Exception catch (error) {
        if (headerOption.ifThrowMaxAgeHeaderError) {
          throw TaroNetworkException(
            url: url,
            error: error,
          );
        }
      }
    }

    final contentType = response.headers['content-type'] ?? '';
    final result = await resizer.resizeIfNeeded(
      bytes: response.bodyBytes,
      contentType: contentType,
      resizeOption: resizeOption,
    );

    return (
      bytes: result.bytes,
      contentType: result.contentType,
      expireAt: expireAt,
    );
  }

  /// Returns the max age from the cache-control header.
  int? _getMaxAge(String cacheControl) {
    // Parse cache-control directives (e.g., "max-age=3600, must-revalidate")
    final directives = cacheControl.split(',').map((e) => e.trim());
    for (final directive in directives) {
      if (directive.startsWith('max-age=')) {
        final maxAgeStr = directive.substring('max-age='.length);
        return int.tryParse(maxAgeStr);
      }
    }
    return null;
  }
}

extension on Uri {
  bool get hasHttpScheme => scheme == 'https' || scheme == 'http';
}
