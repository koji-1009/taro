import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:taro/src/taro_image.dart';
import 'package:taro/src/taro_loader.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';

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

  /// If true, the method checks the cache-control: max-age.
  bool _checkMaxAgeIfExist = false;

  /// If true, the method checks the cache-control: max-age.
  set checkMaxAgeIfExist(bool value) {
    _checkMaxAgeIfExist = value;
  }

  /// If true, the method throws an exception if the max-age header is invalid.
  bool _ifThrowMaxAgeHeaderError = false;

  /// If true, the method throws an exception if the max-age header is invalid.
  set ifThrowMaxAgeHeaderError(bool value) {
    _ifThrowMaxAgeHeaderError = value;
  }

  /// Custom cache duration. If set, this overrides the cache-control header.
  Duration? _customCacheDuration;

  /// Custom cache duration. If set, this overrides the cache-control header.
  set customCacheDuration(Duration? value) {
    _customCacheDuration = value;
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

  /// Changes the current [TaroLoaderStorage] to the provided new loader.
  set storageLoader(TaroLoaderStorage newLoader) {
    _loader.changeStorageLoader(newLoader);
  }

  /// Configures multiple settings at once for better consistency.
  void configure({
    bool? checkMaxAgeIfExist,
    bool? ifThrowMaxAgeHeaderError,
    Duration? customCacheDuration,
    TaroLoaderNetwork? networkLoader,
    TaroLoaderStorage? storageLoader,
  }) {
    if (checkMaxAgeIfExist != null) {
      _checkMaxAgeIfExist = checkMaxAgeIfExist;
    }
    if (ifThrowMaxAgeHeaderError != null) {
      _ifThrowMaxAgeHeaderError = ifThrowMaxAgeHeaderError;
    }
    if (customCacheDuration != null) {
      _customCacheDuration = customCacheDuration;
    }
    if (networkLoader != null) {
      _loader.changeNetworkLoader(networkLoader);
    }
    if (storageLoader != null) {
      _loader.changeStorageLoader(storageLoader);
    }
  }

  /// Loads an image from the provided URL and returns it as a [TaroImage].
  ///
  /// The [headers] parameter is a map of request headers to send with the GET request.
  /// The [cacheWidth] and [cacheHeight] parameters are used to resize the image.
  /// The [checkMaxAgeIfExist] parameter checks the cache-control: max-age.
  /// The [ifThrowMaxAgeHeaderError] parameter throws an exception if the max-age header is invalid.
  /// The [customCacheDuration] parameter overrides the cache-control header.
  ImageProvider loadImageProvider(
    String url, {
    double scale = 1.0,
    Map<String, String> headers = const {},
    int? cacheWidth,
    int? cacheHeight,
    bool? checkMaxAgeIfExist,
    bool? ifThrowMaxAgeHeaderError,
    Duration? customCacheDuration,
  }) {
    final image = TaroImage(
      url,
      scale: scale,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist ?? _checkMaxAgeIfExist,
      ifThrowMaxAgeHeaderError:
          ifThrowMaxAgeHeaderError ?? _ifThrowMaxAgeHeaderError,
      customCacheDuration: customCacheDuration ?? _customCacheDuration,
    );

    return ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      image,
    );
  }

  /// Loads the data from the provided URL and returns it as a byte array.
  /// The [headers] parameter is a map of request headers to send with the GET request.
  Future<Uint8List> loadBytes(
    String url, {
    Map<String, String> headers = const {},
    bool? checkMaxAgeIfExist,
    bool? ifThrowMaxAgeHeaderError,
    Duration? customCacheDuration,
  }) async {
    return await _loader.load(
      url: url,
      headers: headers,
      checkMaxAgeIfExist: checkMaxAgeIfExist ?? _checkMaxAgeIfExist,
      ifThrowMaxAgeHeaderError:
          ifThrowMaxAgeHeaderError ?? _ifThrowMaxAgeHeaderError,
      customCacheDuration: customCacheDuration ?? _customCacheDuration,
    );
  }
}
