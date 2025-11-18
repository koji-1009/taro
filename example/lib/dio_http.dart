import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:taro/taro.dart';

/// [DioHttp] is a class that performs GET requests using the dio package
class DioHttp implements TaroHttpClient {
  /// Creates a [DioHttp].
  const DioHttp({required this.dio});

  final Dio dio;

  @override
  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    final response = await dio.getUri<Uint8List>(
      uri,
      options: Options(headers: headers, responseType: ResponseType.bytes),
    );
    final data = response.data ?? Uint8List(0);
    return (
      statusCode: response.statusCode!,
      bodyBytes: data,
      reasonPhrase: response.statusMessage,
      contentLength: data.length,
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(';')),
      ),
      isRedirect: response.isRedirect,
    );
  }
}
