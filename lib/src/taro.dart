import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:taro/src/loader/loader.dart';
import 'package:taro/src/loader/memory_loader.dart';
import 'package:taro/src/loader/network_loader.dart';
import 'package:taro/src/loader/storage_loader.dart';
import 'package:taro/src/taro_load_result.dart';

typedef ImageProviderWithType = ({
  MemoryImage imageProvider,
  TaroLoadResultType type,
});

typedef BytesWithType = ({
  Uint8List bytes,
  TaroLoadResultType type,
});

class Taro {
  Taro._();

  static final Taro _instance = Taro._();

  static Taro get instance => _instance;

  final _loader = Loader();

  set networkLoader(NetworkLoader newLoader) {
    _loader.changeNetworkLoader(newLoader);
  }

  set memoryLoader(MemoryLoader newLoader) {
    _loader.changeMemoryLoader(newLoader);
  }

  set memoryLoaderMaximumSize(int maximumSize) {
    _loader.changeMemoryLoaderMaximumSize(maximumSize);
  }

  set storageLoader(StorageLoader newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  Future<MemoryImage> loadImageProvider(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
  }) async {
    final result = await loadBytesWithType(
      url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
    );

    return MemoryImage(result.bytes);
  }

  Future<ImageProviderWithType> loadImageProviderWithType(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
  }) async {
    final result = await loadBytesWithType(
      url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
    );

    return (
      imageProvider: MemoryImage(result.bytes),
      type: result.type,
    );
  }

  Future<Uint8List> loadBytes(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
  }) async {
    final result = await loadBytesWithType(
      url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
    );

    return result.bytes;
  }

  Future<BytesWithType> loadBytesWithType(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
  }) async {
    return _loader.load(
      url: url,
      requestHeaders: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
    );
  }
}
