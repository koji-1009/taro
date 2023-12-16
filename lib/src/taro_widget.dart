import 'package:flutter/widgets.dart';
import 'package:taro/src/taro.dart';

typedef TaroWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  ImageProvider imageProvider,
);

typedef TaroPlaceholderBuilder = Widget Function(
  BuildContext context,
  String url,
);

typedef TaroErrorBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

class TaroWidget extends StatefulWidget {
  const TaroWidget({
    super.key,
    required this.url,
    this.contentDisposition,
    this.width,
    this.height,
    this.placeholder,
    this.onError,
    this.onSuccess,
    this.headers = const {},
    this.checkMaxAgeIfExist = false,
  });

  final String url;
  final String? contentDisposition;
  final double? width;
  final double? height;

  final TaroWidgetBuilder? onSuccess;
  final TaroPlaceholderBuilder? placeholder;
  final TaroErrorBuilder? onError;

  final Map<String, String> headers;
  final bool checkMaxAgeIfExist;

  @override
  State<TaroWidget> createState() => _TaroWidgetState();
}

class _TaroWidgetState extends State<TaroWidget> {
  late final futureLoading = Taro.instance.loadImageProvider(
    widget.url,
    headers: widget.headers,
    checkMaxAgeIfExist: widget.checkMaxAgeIfExist,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MemoryImage>(
      future: futureLoading,
      builder: (context, snapshot) {
        final error = snapshot.error;
        if (error != null) {
          return widget.onError?.call(
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
            child: widget.onSuccess?.call(
                  context,
                  widget.url,
                  data,
                ) ??
                Image(
                  image: data,
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
