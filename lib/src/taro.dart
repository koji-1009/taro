import 'dart:typed_data';

import 'package:taro/src/taro_image.dart';
import 'package:taro/src/taro_loader.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';
import 'package:taro/src/taro_resizer.dart';

/// [Taro] is a library for loading images. It uses two loaders: Storage and Network.
class Taro {
  Taro._();

  /// Creates a new instance of the [Taro] class.
  static final Taro _instance = Taro._();

  /// Returns the singleton instance of the [Taro] class.
  static Taro get instance => _instance;

  /// The [TaroLoader] instance used to load data.
  final _loader = TaroLoader();

  /// The [TaroResizeOption] used to resize images.
  TaroResizeOption _resizeOption = const (
    mode: TaroResizeMode.skip,
    maxWidth: null,
    maxHeight: null,
  );

  /// The [TaroResizeOption] used to resize images.
  /// Changing this option will affect all image loading.
  set resizeOption(TaroResizeOption option) {
    _resizeOption = option;
  }

  /// Changes the current [TaroNetworkLoader] to the provided new loader.
  set networkLoader(TaroNetworkLoader newLoader) {
    _loader.changeNetworkLoader(newLoader);
  }

  /// Changes the timeout of the current [TaroNetworkLoader] to the provided duration.
  set networkLoaderTimeout(Duration timeout) {
    _loader.changeNetworkLoader(
      TaroNetworkLoader(
        timeout: timeout,
      ),
    );
  }

  /// Changes the [TaroResizer] of the current [TaroNetworkLoader] to the provided resizer.
  set networkLoaderResizer(TaroResizer resizer) {
    _loader.changeNetworkLoader(
      TaroNetworkLoader(
        resizer: resizer,
      ),
    );
  }

  /// Changes the current [TaroStorageLoader] to the provided new loader.
  set storageLoader(TaroStorageLoader newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  /// Loads an image from the provided URL and returns it as a [TaroImage].
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  TaroImage loadImageProvider(
    String url, {
    double scale = 1.0,
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
    TaroResizeOption? resizeOption,
  }) {
    return TaroImage(
      url,
      scale: scale,
      resizeOption: resizeOption ?? _resizeOption,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
    );
  }

  /// Loads the data from the provided URL and returns it as a byte array.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<Uint8List> loadBytes(
    String url, {
    Map<String, String> headers = const {},
    bool checkMaxAgeIfExist = false,
    TaroResizeOption? resizeOption,
  }) async {
    return await _loader.load(
      url: url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist,
      resizeOption: resizeOption ?? _resizeOption,
    );
  }
}
