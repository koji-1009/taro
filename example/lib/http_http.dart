import 'package:http/http.dart' as http;
import 'package:taro/taro.dart';

/// [HttpHttp] is a class that performs GET requests using the http package
class HttpHttp implements TaroHttpClient {
  /// Creates a [HttpClient].
  const HttpHttp({this.timeout = const Duration(seconds: 180)});

  final Duration timeout;

  @override
  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    final response = await http.get(uri, headers: headers).timeout(timeout);
    return TaroHttpResponse(
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
      reasonPhrase: response.reasonPhrase,
      contentLength: response.contentLength,
      headers: response.headers,
      isRedirect: response.isRedirect,
    );
  }
}
