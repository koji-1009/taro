import 'dart:async';
import 'dart:js_interop';

import 'package:taro/src/network/web_fetch.dart';
import 'package:taro/src/taro_loader_network.dart';

/// Load image data as [TaroHttpResponse] from the network.
Future<TaroHttpResponse> get({
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
}) async {
  final requestHeaders = Headers();
  for (final entry in headers.entries) {
    requestHeaders.append(entry.key, entry.value);
  }
  final response = await fetch(
    uri.toString(),
    requestHeaders,
  ).toDart.timeout(timeout);

  final responseBuffer = await response.arrayBuffer().toDart;
  final responseBytes = responseBuffer.toDart.asUint8List();
  final responseHeaders = <String, String>{};
  response.headers.forEach((String value, String key, JSObject object) {
    responseHeaders[key] = value;
  }.toJS);

  return TaroHttpResponse(
    statusCode: response.status,
    bodyBytes: responseBytes,
    reasonPhrase: response.statusText,
    contentLength: responseBytes.length,
    headers: responseHeaders,
    isRedirect: response.redirected,
  );
}
