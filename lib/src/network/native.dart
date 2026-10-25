import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:taro/src/taro_loader_network.dart';

final _httpClient = HttpClient();

/// Load image data as [TaroHttpResponse] from the network.
///
/// [timeout] limits each wait: the response headers and every next part of
/// the body. A slow download that keeps receiving data does not time out.
Future<TaroHttpResponse> get({
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
}) async {
  // Connecting longer than [timeout] cancels the attempt and throws a
  // SocketException. The client is shared, so the last timeout set applies
  // to new connections; an app uses one timeout in practice.
  _httpClient.connectionTimeout = timeout;
  final request = await _httpClient.getUrl(uri);
  for (final entry in headers.entries) {
    request.headers.add(entry.key, entry.value);
  }
  final response = await request.close().timeout(
    timeout,
    onTimeout: () {
      request.abort();
      throw TimeoutException(
        'The connection has timed out, Please try again.',
        timeout,
      );
    },
  );

  // On a timeout, the subscription is cancelled, which closes the connection.
  final body = response.timeout(timeout);
  final contentLength = response.contentLength;
  final Uint8List responseBytes;
  // A gzip body is decompressed by the client, so its content length is the
  // size before decompression and does not match the bytes read.
  if (contentLength >= 0 &&
      response.compressionState !=
          HttpClientResponseCompressionState.decompressed) {
    // Write into a buffer of the known size instead of copying the chunks
    // again at the end, as consolidateHttpClientResponseBytes does.
    final buffer = Uint8List(contentLength);
    var offset = 0;
    await body.forEach((chunk) {
      buffer.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    });
    // A body shorter than the content length fails with an HttpException,
    // so the buffer is full here.
    responseBytes = buffer;
  } else {
    final bytesBuilder = BytesBuilder(copy: false);
    await body.forEach(bytesBuilder.add);
    responseBytes = bytesBuilder.takeBytes();
  }
  final responseHeaders = <String, String>{};
  response.headers.forEach((key, values) {
    responseHeaders[key] = values.join(',');
  });

  return TaroHttpResponse(
    statusCode: response.statusCode,
    bodyBytes: responseBytes,
    reasonPhrase: response.reasonPhrase,
    contentLength: response.contentLength,
    headers: responseHeaders,
    isRedirect: response.isRedirect,
  );
}
