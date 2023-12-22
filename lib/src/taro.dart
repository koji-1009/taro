import 'dart:typed_data';

import 'package:taro/src/loader/loader.dart';
import 'package:taro/src/loader/network_loader.dart';
import 'package:taro/src/loader/storage_loader.dart';
import 'package:taro/src/taro_image.dart';
import 'package:taro/src/taro_load_result.dart';
import 'package:taro/src/taro_resizer.dart';

/// The default `TaroResizeOption` used by `Taro`.
const TaroResizeOption defaultResizeOption = (
  mode: TaroResizeMode.skip,
  maxWidth: null,
  maxHeight: null,
);

/// Taro is a library for loading images. It uses three loaders: Storage, Memory, and Network.
class Taro {
  Taro._();

  /// Creates a new instance of the `Taro` class.
  static final Taro _instance = Taro._();

  /// Returns the singleton instance of the `Taro` class.
  static Taro get instance => _instance;

  /// The `Loader` instance used to load data.
  final _loader = Loader();

  /// The `TaroResizeOption` used to resize images.
  TaroResizeOption _resizeOption = defaultResizeOption;

  /// The `TaroResizeOption` used to resize images.
  /// Changing this option will affect all image loading.
  set resizeOption(TaroResizeOption option) {
    _resizeOption = option;
  }

  /// Changes the current `NetworkLoader` to the provided new loader.
  set networkLoader(NetworkLoader newLoader) {
    _loader.changeNetworkLoader(newLoader);
  }

  /// Changes the timeout of the current `NetworkLoader` to the provided duration.
  /// The default timeout is 3 minutes.
  set networkLoaderTimeout(Duration timeout) {
    _loader.changeNetworkLoader(
      NetworkLoader(
        timeout: timeout,
      ),
    );
  }

  /// Changes the current `StorageLoader` to the provided new loader.
  set storageLoader(StorageLoader newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  /// Loads an image from the provided URL and returns it as a [TaroImage].
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded `MemoryImage`.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  TaroImage loadImageProvider(
    String url, {
    double scale = 1.0,
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
    TaroResizeOption? resizeOption,
  }) =>
      TaroImage(
        url,
        scale: scale,
        headers: headers,
        checkMaxAgeIfExist: checkMaxAgeIfExist,
        resizeOption: resizeOption ?? _resizeOption,
      );

  /// Loads the data from the provided URL and returns it as a byte array.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded byte array.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<Uint8List> loadBytes(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
    TaroResizeOption? resizeOption,
  }) async {
    final result = await loadBytesWithType(
      url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      resizeOption: resizeOption,
    );

    return result.bytes;
  }

  /// Loads the data from the provided URL and returns it as a `BytesWithType` object.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// Returns a Future that completes with the loaded `BytesWithType` object.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<({Uint8List bytes, TaroLoadResultType type})> loadBytesWithType(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
    TaroResizeOption? resizeOption,
  }) async {
    final result = await _loader.load(
      url: url,
      requestHeaders: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      resizeOption: resizeOption ?? _resizeOption,
    );

    return result;
  }
}
