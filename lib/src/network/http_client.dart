import 'package:http/http.dart' as http;
import 'package:taro/src/taro_loader_network.dart';

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
    final response = await http.get(uri, headers: headers).timeout(timeout);
    return (
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
      reasonPhrase: response.reasonPhrase,
      contentLength: response.contentLength,
      headers: response.headers,
      isRedirect: response.isRedirect,
    );
  }
}
