import 'dart:typed_data';

import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';

/// [TaroLoader] is a class that manages different types of loaders.
class TaroLoader {
  /// Creates a [TaroLoader].
  TaroLoader();

  /// The [TaroLoaderNetwork] instance used to load data from the network.
  /// Loader is able to change the original network loader.
  TaroLoaderNetwork _networkLoader = TaroLoaderNetwork();

  /// The [TaroLoaderStorage] instance used to load data from the storage.
  /// Loader is able to change the original storage loader.
  TaroLoaderStorage _storageLoader = const TaroLoaderStorage();

  /// Changes the current network loader to the provided loader.
  void changeNetworkLoader(TaroLoaderNetwork loader) {
    _networkLoader = loader;
  }

  /// Changes the current storage loader to the provided loader.
  void changeStorageLoader(TaroLoaderStorage loader) {
    _storageLoader = loader;
  }

  /// Loads the data from the provided URL with the given request headers.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  Future<Uint8List> load({
    required String url,
    required Map<String, String> headers,
    bool checkMaxAgeIfExist = false,
    bool ifThrowMaxAgeHeaderError = false,
    Duration? customCacheDuration,
  }) async {
    Uint8List? storageBytes;
    try {
      storageBytes = await _storageLoader.load(
        url: url,
      );
    } on Exception {
      // ignore exception
    }

    if (storageBytes != null) {
      return storageBytes;
    }

    final networkResponse = await _networkLoader.load(
      url: url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      ifThrowMaxAgeHeaderError: ifThrowMaxAgeHeaderError,
      customCacheDuration: customCacheDuration,
    );

    if (networkResponse == null) {
      throw TaroLoadException(
        message: 'Failed to load $url: Network response is null',
      );
    }

    // save to storage
    try {
      await _storageLoader.save(
        url: url,
        bytes: networkResponse.bytes,
        contentType: networkResponse.contentType,
        expireAt: networkResponse.expireAt,
      );
    } on Exception {
      // ignore exception
    }

    return networkResponse.bytes;
  }
}
