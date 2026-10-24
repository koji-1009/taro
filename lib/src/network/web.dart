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
  final Response response;
  final JSArrayBuffer responseBuffer;
  try {
    response = await fetch(
      uri.toString(),
      RequestInit(
        headers: requestHeaders,
      ),
    ).toDart.timeout(timeout);

    responseBuffer = await response.arrayBuffer().toDart;
  } on Exception {
    rethrow;
  } catch (error) {
    // A failed fetch rejects with a JavaScript TypeError, which is not an
    // [Exception]. Wrap it so that it is handled like a native network error.
    throw Exception('[taro][network] Failed to fetch $uri: $error');
  }
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
