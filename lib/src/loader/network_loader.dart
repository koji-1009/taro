import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:taro/src/taro_exception.dart';

typedef NetworkResult = ({
  Uint8List bytes,
  String contentType,
  DateTime? expireAt,
});

class NetworkLoader {
  const NetworkLoader({
    this.timeout = const Duration(
      seconds: 120,
    ),
  });

  final Duration timeout;

  Future<NetworkResult?> load({
    required String url,
    required Map<String, String> requestHeaders,
    required bool checkMaxAgeIfExist,
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
    final cacheControl = response.headers['cache-control']?.toLowerCase() ?? '';
    DateTime? expireAt;
    if (checkMaxAgeIfExist) {
      try {
        if (cacheControl.isNotEmpty) {
          final maxAgePattern = RegExp(r'max-age=(\d+)');
          final match = maxAgePattern.firstMatch(cacheControl);
          if (match != null) {
            final maxAgeStr = match.group(1);
            if (maxAgeStr != null) {
              final maxAge = int.parse(maxAgeStr);
              final now = DateTime.now();
              expireAt = now.add(Duration(seconds: maxAge));
            }
          }
        }
      } catch (error) {
        log('[taro][network] Error parsing cache-control header: $cacheControl');
        log('[taro][network] Url: $url');
        log('[taro][network] Error: $error');
      }
    }

    return (
      bytes: response.bodyBytes,
      contentType: contentType,
      expireAt: expireAt,
    );
  }
}
