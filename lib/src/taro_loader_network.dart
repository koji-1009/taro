import 'dart:async';
import 'dart:typed_data';

import 'package:taro/src/network/http_request.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_resizer.dart';

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
  const TaroHttpClient();

  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  });
}

/// [TaroNetworkLoader] is a class that manages the loading of data from a network source.
/// It uses the http package to send GET requests to the provided URL.
class TaroNetworkLoader {
  const TaroNetworkLoader({
    this.resizer = const TaroResizer(),
    this.client = const HttpClient(),
  });

  factory TaroNetworkLoader.timeout({
    required Duration timeout,
  }) =>
      TaroNetworkLoader(
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
    required bool checkMaxAgeIfExist,
    required TaroResizeOption resizeOption,
  }) async {
    final Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException catch (error) {
      throw TaroUriParseException(
        url: url,
        error: error,
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
    if (checkMaxAgeIfExist) {
      final cacheControl =
          response.headers['cache-control']?.toLowerCase() ?? '';
      final headerAge = response.headers['age']?.toLowerCase() ?? '';
      try {
        if (cacheControl.isNotEmpty) {
          final maxAge = _getMaxAge(cacheControl);
          final age = int.tryParse(headerAge) ?? 0;
          if (maxAge != null) {
            final now = DateTime.now();
            expireAt = now.add(Duration(seconds: maxAge - age));
          }
        }
      } on Exception catch (error) {
        throw TaroNetworkException(
          url: url,
          error: error,
        );
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
      contentType: result.cotentType,
      expireAt: expireAt,
    );
  }

  /// Returns the max age from the cache-control header.
  int? _getMaxAge(String cacheControl) {
    final maxAgePattern = RegExp(r'max-age=(\d+)');
    final match = maxAgePattern.firstMatch(cacheControl);
    if (match != null) {
      final maxAgeStr = match.group(1);
      if (maxAgeStr != null) {
        return int.parse(maxAgeStr);
      }
    }
    return null;
  }
}
