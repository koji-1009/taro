import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:taro/src/network/http_client.dart';
import 'package:taro/src/taro_exception.dart';

/// [TaroHttpResponse] is a class that holds the necessary response information.
@immutable
class TaroHttpResponse {
  /// Creates a [TaroHttpResponse].
  TaroHttpResponse({
    required this.statusCode,
    required this.bodyBytes,
    required Map<String, String> headers,
    this.reasonPhrase,
    this.contentLength,
    this.isRedirect = false,
  }) : headers = headers.map(
          (key, value) => MapEntry(key.toLowerCase(), value),
        );

  /// The status code of the response.
  final int statusCode;

  /// The body bytes of the response.
  final Uint8List bodyBytes;

  /// The reason phrase of the response.
  final String? reasonPhrase;

  /// The content length of the response.
  final int? contentLength;

  /// The headers of the response.
  final Map<String, String> headers;

  /// Whether the response is a redirect.
  final bool isRedirect;

  @override
  String toString() {
    return 'TaroHttpResponse('
        'statusCode: $statusCode, '
        'bodyBytes: ${bodyBytes.length} bytes, '
        'headers: $headers, '
        'reasonPhrase: $reasonPhrase, '
        'contentLength: $contentLength, '
        'isRedirect: $isRedirect'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaroHttpResponse &&
        other.statusCode == statusCode &&
        listEquals(other.bodyBytes, bodyBytes) &&
        other.reasonPhrase == reasonPhrase &&
        other.contentLength == contentLength &&
        mapEquals(other.headers, headers) &&
        other.isRedirect == isRedirect;
  }

  @override
  int get hashCode {
    return Object.hash(
      statusCode,
      Object.hashAll(bodyBytes),
      reasonPhrase,
      contentLength,
      Object.hashAllUnordered(
        headers.entries.map((e) => Object.hash(e.key, e.value)),
      ),
      isRedirect,
    );
  }
}

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

  /// The [TaroHttpClient] instance used to send GET requests.
  final TaroHttpClient client;

  /// Loads the data from the provided URL with the given request headers.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  Future<({Uint8List bytes, String contentType, DateTime? expireAt})?> load({
    required String url,
    required Map<String, String> headers,
    bool checkMaxAgeIfExist = false,
    bool ifThrowMaxAgeHeaderError = false,
    Duration? customCacheDuration,
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
    if (customCacheDuration != null) {
      final now = clock.now();
      expireAt = now.add(customCacheDuration);
    } else if (checkMaxAgeIfExist) {
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
        if (ifThrowMaxAgeHeaderError) {
          throw TaroNetworkException(
            url: url,
            error: error,
          );
        }
      }
    }

    final contentType = response.headers['content-type'] ?? '';

    return (
      bytes: response.bodyBytes,
      contentType: contentType,
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
