import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

typedef NetworkResult = ({
  Uint8List bytes,
  String contentType,
  DateTime? expireAt,
});

class NetworkLoader {
  const NetworkLoader();

  Future<NetworkResult?> load({
    required String url,
    required Map<String, String> requestHeaders,
    required bool checkMaxAgeIfExist,
  }) async {
    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: requestHeaders,
    );

    final contentType = response.headers['content-type'] ?? '';
    final cacheControl = response.headers['cache-control']?.toLowerCase();

    DateTime? expireAt;
    if (checkMaxAgeIfExist) {
      try {
        if (cacheControl != null) {
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
