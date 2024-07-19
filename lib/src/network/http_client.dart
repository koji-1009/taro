import 'dart:async';

import 'package:taro/src/taro_loader_network.dart';

import 'shared.dart' as client;

/// [HttpClient] is a class that manages the sending of GET requests to the provided URL.
class HttpClient implements TaroHttpClient {
  /// Creates a [HttpClient].
  const HttpClient({
    this.timeout = const Duration(
      seconds: 180,
    ),
  });

  final Duration timeout;

  @override
  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    final response = await client
        .get(
          uri: uri,
          headers: headers,
        )
        .timeout(timeout);

    return response;
  }
}
