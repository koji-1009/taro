import 'dart:typed_data';

import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';
import 'package:taro/src/taro_loader_type.dart';
import 'package:taro/src/taro_resizer.dart';

/// [TaroLoader] is a class that manages different types of loaders.
class TaroLoader {
  TaroLoader();

  /// The [TaroNetworkLoader] instance used to load data from the network.
  /// Loader is able to change the original network loader.
  TaroNetworkLoader _networkLoader = const TaroNetworkLoader();

  /// The [TaroStorageLoader] instance used to load data from the storage.
  /// Loader is able to change the original storage loader.
  TaroStorageLoader _storageLoader = const TaroStorageLoader();

  /// Changes the current network loader to the provided loader.
  void changeNetworkLoader(TaroNetworkLoader loader) {
    _networkLoader = loader;
  }

  /// Changes the current storage loader to the provided loader.
  void changeStorageLoader(TaroStorageLoader loader) {
    _storageLoader = loader;
  }

  /// Loads the data from the provided URL with the given request headers.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<({Uint8List bytes, TaroLoaderType type})> load({
    required String url,
    required Map<String, String> headers,
    required checkMaxAgeIfExist,
    required TaroResizeOption resizeOption,
  }) async {
    final storageBytes = await _storageLoader.load(
      url: url,
      resizeOption: resizeOption,
    );
    if (storageBytes != null) {
      return (
        bytes: storageBytes,
        type: TaroLoaderType.storage,
      );
    }

    final networkResponse = await _networkLoader.load(
      url: url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      resizeOption: resizeOption,
    );

    if (networkResponse != null) {
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
        type: TaroLoaderType.network,
      );
    }

    throw TaroLoadException(
      message: 'Failed to load $url',
    );
  }
}
