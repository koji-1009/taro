import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_load_result.dart';
import 'package:taro/src/taro_resizer.dart';

/// A builder that creates a widget from the loaded data.
typedef TaroWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  ImageProvider imageProvider,
  TaroLoadResultType type,
);

/// A builder that creates a widget when an error occurs while loading the data.
typedef TaroErrorBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

/// A builder that creates a placeholder widget while the data is loading.
typedef TaroPlaceholderBuilder = Widget Function(
  BuildContext context,
  String url,
);

/// TaroWidget is a widget for loading images. It uses three loaders: Storage, Memory, and Network.
class TaroWidget extends StatefulWidget {
  const TaroWidget({
    super.key,
    required this.url,
    this.fit,
    this.contentDisposition,
    this.width,
    this.height,
    this.builder,
    this.errorBuilder,
    this.placeholder,
    this.headers = const {},
    this.checkMaxAgeIfExist = false,
    this.resizeOption,
  });

  /// The URL from which the widget loads data.
  final String url;

  /// How to inscribe the image into the space allocated during layout.
  final BoxFit? fit;

  /// The content disposition of the data.
  final String? contentDisposition;

  /// The width of the widget.
  final double? width;

  /// The height of the widget.
  final double? height;

  /// A builder that creates a widget from the loaded data.
  final TaroWidgetBuilder? builder;

  /// A builder that creates a widget when an error occurs while loading the data.
  final TaroErrorBuilder? errorBuilder;

  /// A builder that creates a placeholder widget while the data is loading.
  final TaroPlaceholderBuilder? placeholder;

  /// A map of request headers to send with the GET request.
  final Map<String, String> headers;

  /// Whether to check the max age of the data.
  final bool checkMaxAgeIfExist;

  /// The resize option used to resize the image.
  final TaroResizeOption? resizeOption;

  @override
  State<TaroWidget> createState() => _TaroWidgetState();
}

class _TaroWidgetState extends State<TaroWidget> {
  late final futureLoading = Taro.instance.loadImageProviderWithType(
    widget.url,
    headers: widget.headers,
    checkMaxAgeIfExist: widget.checkMaxAgeIfExist,
    resizeOption: widget.resizeOption,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProviderWithType>(
      future: futureLoading,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return widget.errorBuilder?.call(
                context,
                widget.url,
                error,
              ) ??
              SizedBox(
                width: widget.width,
                height: widget.height,
              );
        }

        final data = snapshot.data;
        if (data != null) {
          return Semantics(
            label: widget.contentDisposition,
            child: widget.builder?.call(
                  context,
                  widget.url,
                  data.imageProvider,
                  data.type,
                ) ??
                Image(
                  image: data.imageProvider,
                  fit: widget.fit,
                  width: widget.width,
                  height: widget.height,
                ),
          );
        }

        return widget.placeholder?.call(
              context,
              widget.url,
            ) ??
            SizedBox(
              width: widget.width,
              height: widget.height,
            );
      },
    );
  }
}
