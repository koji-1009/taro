import 'package:dio/dio.dart';
import 'package:example/app.dart';
import 'package:example/dio_http.dart';
import 'package:flutter/material.dart';
import 'package:taro/taro.dart';

void main() {
  const useDio = true;
  if (useDio) {
    Taro.instance.networkLoader = TaroLoaderNetwork(
      client: DioHttp(
        dio: Dio()
          ..options.connectTimeout = const Duration(seconds: 10)
          ..options.receiveTimeout = const Duration(seconds: 10),
      ),
    );
  }

  runApp(const App());
}
