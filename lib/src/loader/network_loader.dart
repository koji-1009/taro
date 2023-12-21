import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_resizer.dart';

typedef NetworkResult = ({
  Uint8List bytes,
  String contentType,
  DateTime? expireAt,
});

/// `NetworkLoader` is a class that manages the loading of data from a network source.
/// It uses the http package to send GET requests to the provided URL.
class NetworkLoader {
  /// Creates a new instance of `NetworkLoader`.
  /// The [timeout] parameter sets the timeout for the GET request.
  const NetworkLoader({
    this.timeout = const Duration(
      /// The default timeout is 3 minutes.
      seconds: 180,
    ),
  });

  /// The timeout Duration for the GET request.
  final Duration timeout;

  /// Loads the data from the provided URL with the given request headers.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with a `NetworkResult` object.
  Future<NetworkResult?> load({
    required String url,
    required Map<String, String> requestHeaders,
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

    final http.Response response;
    try {
      response = await http
          .get(
            uri,
            headers: requestHeaders,
          )
          .timeout(timeout);
    } on Exception catch (error) {
      throw TaroNetworkException(
        url: url,
        error: error,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw TaroHttpResponseException(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        contentLength: response.contentLength,
        headers: response.headers,
        isRedirect: response.isRedirect,
      );
    }

    final contentType = response.headers['content-type'] ?? '';
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
        log('[taro][network] Error parsing cache-control header: $cacheControl');
        log('[taro][network] Url: $url');
        log('[taro][network] Error: $error');
      }
    }

    final result = await TaroResizer.resizeIfNeeded(
      bytes: response.bodyBytes,
      contentType: contentType,
      option: resizeOption,
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
