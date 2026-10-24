import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:taro/src/taro_loader_network.dart';

final _httpClient = HttpClient();

/// Load image data as [TaroHttpResponse] from the network.
Future<TaroHttpResponse> get({
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
}) async {
  HttpClientRequest? request;
  var timedOut = false;

  // The timeout covers the whole request: connecting, receiving the headers
  // and reading the body.
  Future<TaroHttpResponse> send() async {
    final openedRequest = await _httpClient.getUrl(uri);
    request = openedRequest;
    if (timedOut) {
      // The timeout fired while connecting.
      openedRequest.abort();
      throw TimeoutException(null, timeout);
    }
    for (final entry in headers.entries) {
      openedRequest.headers.add(entry.key, entry.value);
    }
    final response = await openedRequest.close();

    final responseBytes = await consolidateHttpClientResponseBytes(response);
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

  return send().timeout(
    timeout,
    onTimeout: () {
      timedOut = true;
      request?.abort();
      throw TimeoutException(
        'The connection has timed out, Please try again.',
        timeout,
      );
    },
  );
}
