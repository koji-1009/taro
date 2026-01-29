import 'dart:typed_data';

import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';
import 'package:taro/src/taro_type.dart';

/// [TaroLoader] is a class that manages different types of loaders.
class TaroLoader {
  /// Creates a [TaroLoader].
  TaroLoader();

  /// The [TaroLoaderNetwork] instance used to load data from the network.
  /// Loader is able to change the original network loader.
  TaroLoaderNetwork _networkLoader = const TaroLoaderNetwork();

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
    required TaroHeaderOption headerOption,
  }) async {
    final storageBytes = await _storageLoader.load(
      url: url,
    );
    if (storageBytes != null) {
      return storageBytes;
    }

    final networkResponse = await _networkLoader.load(
      url: url,
      headers: headers,
      headerOption: headerOption,
    );

    if (networkResponse == null) {
      throw TaroLoadException(
        message: 'Failed to load $url: Network response is null',
      );
    }

    // save to storage
    await _storageLoader.save(
      url: url,
      bytes: networkResponse.bytes,
      contentType: networkResponse.contentType,
      expireAt: networkResponse.expireAt,
    );

    return networkResponse.bytes;
  }
}
