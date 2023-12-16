import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_load_result.dart';

typedef TaroWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  ImageProvider imageProvider,
  TaroLoadResultType type,
);

typedef TaroErrorBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

typedef TaroPlaceholderBuilder = Widget Function(
  BuildContext context,
  String url,
);

class TaroWidget extends StatefulWidget {
  const TaroWidget({
    super.key,
    required this.url,
    this.contentDisposition,
    this.width,
    this.height,
    this.builder,
    this.errorBuilder,
    this.placeholder,
    this.headers = const {},
    this.checkMaxAgeIfExist = false,
  });

  final String url;
  final String? contentDisposition;
  final double? width;
  final double? height;

  final TaroWidgetBuilder? builder;
  final TaroErrorBuilder? errorBuilder;
  final TaroPlaceholderBuilder? placeholder;

  final Map<String, String> headers;
  final bool checkMaxAgeIfExist;

  @override
  State<TaroWidget> createState() => _TaroWidgetState();
}

class _TaroWidgetState extends State<TaroWidget> {
  late final futureLoading = Taro.instance.loadImageProviderWithType(
    widget.url,
    headers: widget.headers,
    checkMaxAgeIfExist: widget.checkMaxAgeIfExist,
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
