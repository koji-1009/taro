import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:taro/src/taro_image.dart';
import 'package:taro/src/taro_loader.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';
import 'package:taro/src/taro_resizer.dart';
import 'package:taro/src/taro_type.dart';

/// [Taro] is a library for loading images. It uses two loaders: Storage and Network.
class Taro {
  /// Creates a [Taro].
  Taro._();

  /// Creates a new instance of the [Taro] class.
  static final Taro _instance = Taro._();

  /// Returns the singleton instance of the [Taro] class.
  static Taro get instance => _instance;

  /// The [TaroLoader] instance used to load data.
  final _loader = TaroLoader();

  /// The [TaroResizeOption] used to resize images.
  TaroResizeOption _resizeOption = const TaroResizeOptionSkip();

  /// The [TaroResizeOption] used to resize images.
  /// Changing this option will affect all image loading.
  set resizeOption(TaroResizeOption option) {
    _resizeOption = option;
  }

  /// The [TaroHeaderOption] used to check cache-control header.
  TaroHeaderOption _headerOption = const (
    checkMaxAgeIfExist: false,
    ifThrowMaxAgeHeaderError: false,
  );

  /// The [TaroHeaderOption] used to check cache-control header.
  set headerOption(TaroHeaderOption option) {
    _headerOption = option;
  }

  /// Changes the current [TaroLoaderNetwork] to the provided new loader.
  set networkLoader(TaroLoaderNetwork newLoader) {
    _loader.changeNetworkLoader(newLoader);
  }

  /// Changes the timeout of the current [TaroLoaderNetwork] to the provided duration.
  set networkLoaderTimeout(Duration timeout) {
    _loader.changeNetworkLoader(
      TaroLoaderNetwork.timeout(
        timeout: timeout,
      ),
    );
  }

  /// Changes the [TaroResizer] of the current [TaroLoaderNetwork] to the provided resizer.
  set networkLoaderResizer(TaroResizer resizer) {
    _loader.changeNetworkLoader(
      TaroLoaderNetwork(
        resizer: resizer,
      ),
    );
  }

  /// Changes the current [TaroLoaderStorage] to the provided new loader.
  set storageLoader(TaroLoaderStorage newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  /// Configures multiple settings at once for better consistency.
  void configure({
    TaroResizeOption? resizeOption,
    TaroHeaderOption? headerOption,
    TaroLoaderNetwork? networkLoader,
    TaroLoaderStorage? storageLoader,
  }) {
    if (resizeOption != null) {
      _resizeOption = resizeOption;
    }
    if (headerOption != null) {
      _headerOption = headerOption;
    }
    if (networkLoader != null) {
      _loader.changeNetworkLoader(networkLoader);
    }
    if (storageLoader != null) {
      _loader.changeStorageLoader(storageLoader);
    }
  }

  /// Loads an image from the provided URL and returns it as a [TaroImage].
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// If [checkMaxAgeIfExist] is true, the method checks the max age of the data.
  /// [ifThrowMaxAgeHeaderError] is used to throw an exception if the max age header is invalid.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  ImageProvider loadImageProvider(
    String url, {
    double scale = 1.0,
    Map<String, String> headers = const {},
    TaroResizeOption? resizeOption,
    TaroHeaderOption? headerOption,
  }) {
    final image = TaroImage(
      url,
      scale: scale,
      resizeOption: resizeOption ?? _resizeOption,
      headers: headers,
      headerOption: headerOption ?? _headerOption,
    );

    if (resizeOption is TaroResizeOptionMemory) {
      return ResizeImage.resizeIfNeeded(
        resizeOption.maxWidth,
        resizeOption.maxHeight,
        image,
      );
    }

    return image;
  }

  /// Loads the data from the provided URL and returns it as a byte array.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
  Future<Uint8List> loadBytes(
    String url, {
    Map<String, String> headers = const {},
    TaroResizeOption? resizeOption,
    TaroHeaderOption? headerOption,
  }) async {
    return await _loader.load(
      url: url,
      headers: headers,
      resizeOption: resizeOption ?? _resizeOption,
      headerOption: headerOption ?? _headerOption,
    );
  }
}
