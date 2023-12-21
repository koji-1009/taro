import 'dart:typed_data';

import 'package:taro/src/loader/memory_loader.dart';
import 'package:taro/src/loader/network_loader.dart';
import 'package:taro/src/loader/storage_loader.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_load_result.dart';
import 'package:taro/src/taro_resizer.dart';

const maximumMemoryCacheSize = 40;

/// `Loader` is a class that manages different types of loaders.
class Loader {
  Loader();

  NetworkLoader _networkLoader = const NetworkLoader();
  MemoryLoader _memoryLoader = MemoryLoader(
    maximumSize: maximumMemoryCacheSize,
  );
  StorageLoader _storageLoader = const StorageLoader();

  /// Changes the current network loader to the provided loader.
  void changeNetworkLoader(NetworkLoader loader) {
    _networkLoader = loader;
  }

  /// Changes the timeout of the current network loader.
  void changeNetworkLoaderTimeout(Duration timeout) {
    _networkLoader = NetworkLoader(
      timeout: timeout,
    );
  }

  /// Changes the current memory loader to the provided loader.
  void changeMemoryLoader(MemoryLoader loader) {
    _memoryLoader = loader;
  }

  /// Changes the maximum size of the current memory loader.
  void changeMemoryLoaderMaximumSize(int maximumSize) {
    _memoryLoader = MemoryLoader(
      maximumSize: maximumSize,
    );
  }

  /// Changes the current storage loader to the provided loader.
  void changeStorageLoader(StorageLoader loader) {
    _storageLoader = loader;
  }

  /// Loads the data from the provided URL with the given request headers.
  /// Returns a Future that completes with a map containing the loaded bytes and the type of the load result.
  Future<({Uint8List bytes, TaroLoadResultType type})> load({
    required String url,
    required Map<String, String> requestHeaders,
    required checkMaxAgeIfExist,
    required TaroResizeOption resizeOption,
  }) async {
    final memoryCache = await _memoryLoader.load(
      url: url,
      resizeOption: resizeOption,
    );
    if (memoryCache != null) {
      return (
        bytes: memoryCache,
        type: TaroLoadResultType.memory,
      );
    }

    final storageCache = await _storageLoader.load(
      url: url,
      resizeOption: resizeOption,
    );
    if (storageCache != null) {
      // save to memory
      await _memoryLoader.save(
        url: url,
        bytes: storageCache.bytes,
        expireAt: storageCache.info.expireAt,
        resizeOption: resizeOption,
      );

      return (
        bytes: storageCache.bytes,
        type: TaroLoadResultType.storage,
      );
    }

    final networkResponse = await _networkLoader.load(
      url: url,
      requestHeaders: requestHeaders,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      resizeOption: resizeOption,
    );

    if (networkResponse != null) {
      // save to memory
      await _memoryLoader.save(
        url: url,
        bytes: networkResponse.bytes,
        expireAt: networkResponse.expireAt,
        resizeOption: resizeOption,
      );

      // save to storage
      await _storageLoader.save(
        url: url,
        bytes: networkResponse.bytes,
        contentType: networkResponse.contentType,
        expireAt: networkResponse.expireAt,
        resizeOption: resizeOption,
      );

      return (
        bytes: networkResponse.bytes,
        type: TaroLoadResultType.network,
      );
    }

    throw TaroLoadException(
      message: 'Failed to load $url',
    );
  }
}
