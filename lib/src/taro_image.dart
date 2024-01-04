import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_type.dart';

/// [TaroImage] is an [ImageProvider] that loads images from the network and caches them.
@immutable
class TaroImage extends ImageProvider<TaroImage> {
  const TaroImage(
    this.url, {
    this.scale = 1.0,
    this.resizeOption,
    this.useHeadersHashCode = false,
    this.headers = const {},
    this.headerOption,
  });

  /// The URL from which the image is loaded.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The resize option used to resize the image.
  final TaroResizeOption? resizeOption;

  /// Use network options to identify instances
  /// If [useHeadersHashCode] is true, the [headers] and [checkMaxAgeIfExist] are used to identify instances.
  final bool useHeadersHashCode;

  /// The HTTP headers that will be used in the GET request.
  final Map<String, String> headers;

  /// The header option used to handle response header.
  final TaroHeaderOption? headerOption;

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
        resizeOption: key.resizeOption,
        headerOption: key.headerOption,
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

    if (useHeadersHashCode) {
      return other is TaroImage &&
          other.url == url &&
          other.scale == scale &&
          other.resizeOption == resizeOption &&
          other.headers == headers &&
          other.headerOption == headerOption;
    }

    return other is TaroImage &&
        other.url == url &&
        other.scale == scale &&
        other.resizeOption == resizeOption;
  }

  @override
  int get hashCode => useHeadersHashCode
      ? Object.hash(url, scale, resizeOption, headers, headerOption)
      : Object.hash(url, scale, resizeOption);

  @override
  String toString() => ''
      '${objectRuntimeType(this, 'TaroImage')}(url: $url, scale: $scale, resizeOption: $resizeOption, useHeadersInHashCode: $useHeadersHashCode, headers: $headers, headerOption: $headerOption)';
}
