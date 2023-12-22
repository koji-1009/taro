import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_resizer.dart';

/// A builder that creates a widget when the data is loaded.
typedef TaroImageFrameBuilder = ImageFrameBuilder;

/// A builder that creates a widget when an error occurs while loading the data.
typedef TaroErrorBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
  StackTrace? stackTrace,
);

/// A builder that creates a placeholder widget while the data is loading.
typedef TaroPlaceholderBuilder = Widget Function(
  BuildContext context,
  String url,
);

/// [TaroWidget] is a widget for loading images. It uses two loaders: Storage and Network.
/// Images that have been loaded once are cached in [ImageCache].
class TaroWidget extends StatelessWidget {
  const TaroWidget({
    super.key,
    required this.url,
    this.headers = const {},
    this.checkMaxAgeIfExist = false,
    this.resizeOption,
    this.scale = 1.0,
    this.frameBuilder,
    this.errorBuilder,
    this.placeholder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  });

  /// The URL from which the widget loads data.
  final String url;

  /// A map of request headers to send with the GET request.
  final Map<String, String> headers;

  /// Whether to check the max age of the data.
  final bool checkMaxAgeIfExist;

  /// The resize option used to resize the image.
  final TaroResizeOption? resizeOption;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// A builder that creates a widget when the data is loaded.
  final TaroImageFrameBuilder? frameBuilder;

  /// A builder that creates a widget when an error occurs while loading the data.
  final TaroErrorBuilder? errorBuilder;

  /// A builder that creates a placeholder widget while the data is loading.
  final TaroPlaceholderBuilder? placeholder;

  /// see [Image.semanticLabel]
  final String? semanticLabel;

  /// see [Image.excludeFromSemantics]
  final bool excludeFromSemantics;

  /// see [Image.width]
  final double? width;

  /// see [Image.height]
  final double? height;

  /// see [Image.color]
  final Color? color;

  /// see [Image.opacity]
  final Animation<double>? opacity;

  /// see [Image.filterQuality]
  final FilterQuality filterQuality;

  /// see [Image.colorBlendMode]
  final BlendMode? colorBlendMode;

  /// see [Image.fit]
  final BoxFit? fit;

  /// see [Image.alignment]
  final AlignmentGeometry alignment;

  /// see [Image.repeat]
  final ImageRepeat repeat;

  /// see [Image.centerSlice]
  final Rect? centerSlice;

  /// see [Image.matchTextDirection]
  final bool matchTextDirection;

  /// see [Image.gaplessPlayback]
  final bool gaplessPlayback;

  /// see [Image.isAntiAlias]
  final bool isAntiAlias;

  @override
  Widget build(BuildContext context) {
    return Image(
      key: key,
      image: Taro.instance.loadImageProvider(
        url,
        headers: headers,
        checkMaxAgeIfExist: checkMaxAgeIfExist,
        resizeOption: resizeOption,
        scale: scale,
      ),
      frameBuilder: frameBuilder,
      loadingBuilder: placeholder != null
          ? (context, child, loadingProgress) =>
              loadingProgress == null ? child : placeholder!(context, url)
          : null,
      errorBuilder: errorBuilder != null
          ? (context, error, stackTrace) =>
              errorBuilder!(context, url, error, stackTrace)
          : null,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }
}
