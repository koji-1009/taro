import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:taro/src/loader/loader.dart';
import 'package:taro/src/loader/memory_loader.dart';
import 'package:taro/src/loader/network_loader.dart';
import 'package:taro/src/loader/storage_loader.dart';
import 'package:taro/src/taro_load_result.dart';

/// A function that returns a `MemoryImage` and a `TaroLoadResultType`.
typedef ImageProviderWithType = ({
  MemoryImage imageProvider,
  TaroLoadResultType type,
});

/// A function that returns a byte array and a `TaroLoadResultType`.
typedef BytesWithType = ({
  Uint8List bytes,
  TaroLoadResultType type,
});

/// Taro is a library for loading images. It uses three loaders: Storage, Memory, and Network.
class Taro {
  Taro._();

  /// Creates a new instance of the `Taro` class.
  static final Taro _instance = Taro._();

  /// Returns the singleton instance of the `Taro` class.
  static Taro get instance => _instance;

  /// The `Loader` instance used to load data.
  final _loader = Loader();

  /// Changes the current `NetworkLoader` to the provided new loader.
  set networkLoader(NetworkLoader newLoader) {
    _loader.changeNetworkLoader(newLoader);
  }

  /// Changes the timeout of the current `NetworkLoader` to the provided duration.
  set networkLoaderTimeout(Duration timeout) {
    _loader.changeNetworkLoaderTimeout(timeout);
  }

  /// Changes the current `MemoryLoader` to the provided new loader.
  set memoryLoader(MemoryLoader newLoader) {
    _loader.changeMemoryLoader(newLoader);
  }

  /// Changes the maximum size of the current `MemoryLoader` to the provided size.
  set memoryLoaderMaximumSize(int maximumSize) {
    _loader.changeMemoryLoaderMaximumSize(maximumSize);
  }

  /// Changes the current `StorageLoader` to the provided new loader.
  set storageLoader(StorageLoader newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  /// Loads an image from the provided URL and returns it as a `MemoryImage`.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded `MemoryImage`.
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

  /// Loads an image from the provided URL and returns it as an `ImageProviderWithType`.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded `ImageProviderWithType`.
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

  /// Loads the data from the provided URL and returns it as a byte array.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded byte array.
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

  /// Loads the data from the provided URL and returns it as a `BytesWithType` object.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded `BytesWithType` object.
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
