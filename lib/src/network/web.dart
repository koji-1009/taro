import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:taro/src/network/web_fetch.dart';
import 'package:taro/src/taro_loader_network.dart';

/// Load image data as [TaroHttpResponse] from the network.
///
/// [timeout] limits each wait: the response headers and every next part of
/// the body. A slow download that keeps receiving data does not time out.
Future<TaroHttpResponse> get({
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
}) async {
  final requestHeaders = Headers();
  for (final entry in headers.entries) {
    requestHeaders.append(entry.key, entry.value);
  }
  final abortController = AbortController();
  Never onTimeout() {
    // Stop the request instead of leaving it running in the background.
    abortController.abort();
    throw TimeoutException(null, timeout);
  }

  final Response response;
  final bytesBuilder = BytesBuilder(copy: false);
  try {
    response = await fetch(
      uri.toString(),
      RequestInit(
        headers: requestHeaders,
        signal: abortController.signal,
      ),
    ).toDart.timeout(timeout, onTimeout: onTimeout);

    // A response without a body, such as 204, has no stream to read.
    final reader = response.body?.getReader();
    if (reader != null) {
      while (true) {
        final result =
            await reader.read().toDart.timeout(timeout, onTimeout: onTimeout);
        if (result.done) {
          break;
        }
        bytesBuilder.add(result.value!.toDart);
      }
    }
  } on Exception {
    rethrow;
  } catch (error) {
    // A failed fetch rejects with a JavaScript TypeError, which is not an
    // [Exception]. Wrap it so that it is handled like a native network error.
    throw Exception('[taro][network] Failed to fetch $uri: $error');
  }
  final responseBytes = bytesBuilder.takeBytes();
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
