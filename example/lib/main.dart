import 'package:dio/dio.dart';
import 'package:example/app.dart';
import 'package:example/dio_http.dart';
import 'package:example/http_http.dart';
import 'package:flutter/material.dart';
import 'package:taro/taro.dart';

enum HttpMode {
  http,
  dio,
  none,
}

void main() {
  const mode = HttpMode.none;
  switch (mode) {
    case HttpMode.http:
      Taro.instance.networkLoader = const TaroLoaderNetwork(
        client: HttpHttp(),
      );
    case HttpMode.dio:
      Taro.instance.networkLoader = TaroLoaderNetwork(
        client: DioHttp(
          dio: Dio()
            ..options.connectTimeout = const Duration(seconds: 10)
            ..options.receiveTimeout = const Duration(seconds: 10),
        ),
      );
    case HttpMode.none:
      break;
  }

  runApp(const App());
}
