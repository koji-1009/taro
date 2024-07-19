import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:taro/src/taro_loader_network.dart';

final _httpClient = HttpClient()..autoUncompress = false;

/// Load image data as [TaroHttpResponse] from the network.
Future<TaroHttpResponse> get({
  required Uri uri,
  required Map<String, String> headers,
}) async {
  final request = await _httpClient.getUrl(uri);
  for (final entry in headers.entries) {
    request.headers.add(entry.key, entry.value);
  }
  final response = await request.close();

  final responseBytes = await consolidateHttpClientResponseBytes(response);
  final responseHeaders = <String, String>{};
  response.headers.forEach((key, values) {
    responseHeaders[key] = values.join(',');
  });

  return (
    statusCode: response.statusCode,
    bodyBytes: responseBytes,
    reasonPhrase: response.reasonPhrase,
    contentLength: response.contentLength,
    headers: responseHeaders,
    isRedirect: response.isRedirect,
  );
}
