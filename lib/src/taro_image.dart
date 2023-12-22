import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_resizer.dart';

/// TaroImage is an [ImageProvider] that loads images from the [Taro].
/// It uses two loaders: Storage and Network.
/// The [url] parameter is the URL from which the image is loaded.
/// The [scale] parameter is the scale to place in the [ImageInfo] object of the image.
/// The [headers] parameter is the HTTP headers that will be used in the GET request.
/// The [checkMaxAgeIfExist] parameter is whether to check the max age of the data.
/// The [resizeOption] parameter is used to resize the image. If it is not provided, the default resize option is used.
@immutable
class TaroImage extends ImageProvider<TaroImage> {
  const TaroImage(
    this.url, {
    this.scale = 1.0,
    this.headers = const {},
    this.checkMaxAgeIfExist = false,
    this.resizeOption = defaultResizeOption,
  });

  /// The URL from which the image is loaded.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used in the GET request.
  final Map<String, String> headers;

  /// Whether to check the max age of the data.
  final bool checkMaxAgeIfExist;

  /// The resize option used to resize the image.
  final TaroResizeOption resizeOption;

  @override
  Future<TaroImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<TaroImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(TaroImage key, ImageDecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();
    // notify that the image is loading
    chunkEvents.add(
      const ImageChunkEvent(
        cumulativeBytesLoaded: 1,
        expectedTotalBytes: null,
      ),
    );

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode: decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<TaroImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    TaroImage key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required ImageDecoderCallback decode,
  }) async {
    try {
      assert(key == this);
      final bytes = await Taro.instance.loadBytes(
        key.url,
        headers: key.headers,
        checkMaxAgeIfExist: key.checkMaxAgeIfExist,
        resizeOption: key.resizeOption,
      );

      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is TaroImage &&
        other.url == url &&
        other.scale == scale &&
        other.headers == headers &&
        other.checkMaxAgeIfExist == checkMaxAgeIfExist &&
        other.resizeOption == resizeOption;
  }

  @override
  int get hashCode =>
      Object.hash(url, scale, headers, checkMaxAgeIfExist, resizeOption);

  @override
  String toString() => ''
      '${objectRuntimeType(this, 'TaroImage')}(url: $url, scale: $scale, headers: $headers, checkMaxAgeIfExist: $checkMaxAgeIfExist, resizeOption: $resizeOption, )';
}
