import 'dart:typed_data';

import 'package:taro/src/loader/memory_loader.dart';
import 'package:taro/src/loader/network_loader.dart';
import 'package:taro/src/loader/storage_loader.dart';
import 'package:taro/src/taro_load_result.dart';

const maximumMemoryCacheSize = 40;

class Loader {
  Loader();

  NetworkLoader _networkLoader = const NetworkLoader();
  MemoryLoader _memoryLoader = MemoryLoader(
    maximumSize: maximumMemoryCacheSize,
  );
  StorageLoader _storageLoader = const StorageLoader();

  void changeNetworkLoader(NetworkLoader loader) {
    _networkLoader = loader;
  }

  void changeNetworkLoaderTimeout(Duration timeout) {
    _networkLoader = NetworkLoader(
      timeout: timeout,
    );
  }

  void changeMemoryLoader(MemoryLoader loader) {
    _memoryLoader = loader;
  }

  void changeMemoryLoaderMaximumSize(int maximumSize) {
    _memoryLoader = MemoryLoader(
      maximumSize: maximumSize,
    );
  }

  void changeStorageLoader(StorageLoader loader) {
    _storageLoader = loader;
  }

  Future<({Uint8List bytes, TaroLoadResultType type})> load({
    required String url,
    required Map<String, String> requestHeaders,
    required checkMaxAgeIfExist,
  }) async {
    final memoryCache = await _memoryLoader.load(
      url: url,
    );
    if (memoryCache != null) {
      return (
        bytes: memoryCache,
        type: TaroLoadResultType.memory,
      );
    }

    final storageCache = await _storageLoader.load(
      url: url,
    );
    if (storageCache != null) {
      // save to memory
      await _memoryLoader.save(
        url: url,
        bytes: storageCache.bytes,
        expireAt: storageCache.info.expireAt,
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
    );

    if (networkResponse != null) {
      // save to memory
      await _memoryLoader.save(
        url: url,
        bytes: networkResponse.bytes,
        expireAt: networkResponse.expireAt,
      );

      // save to storage
      await _storageLoader.save(
        url: url,
        bytes: networkResponse.bytes,
        contentType: networkResponse.contentType,
        expireAt: networkResponse.expireAt,
      );

      return (
        bytes: networkResponse.bytes,
        type: TaroLoadResultType.network,
      );
    }

    throw Exception('[taro][loader] load failed');
  }
}
