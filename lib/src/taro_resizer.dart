import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:taro/src/taro_exception.dart';

/// The `TaroResizeMode` enum is used to determine how images are resized.
enum TaroResizeMode {
  /// The image is not resized.
  skip,

  /// The image is resized to the original contentType.
  original,

  /// The image is resized to a png.
  png,

  /// The image is resized to a jpg.
  jpg,
}

/// The `TaroResizeException` class is used to throw exceptions when resizing images.
typedef TaroResizeOption = ({
  /// The resize mode of the image.
  TaroResizeMode mode,

  /// The maximum width of the image. If null, the width is not limited.
  int? maxWidth,

  /// The maximum height of the image. If null, the height is not limited.
  int? maxHeight,
});

/// The `TaroResizer` class is used to resize images.
class TaroResizer {
  TaroResizer._();

  /// Creates a new instance of the `TaroResizer` class.
  /// The [resizeOption] parameter sets the resize option of the resizer.
  static Future<({Uint8List bytes, String cotentType})> resizeIfNeeded({
    required Uint8List bytes,
    required String contentType,
    required TaroResizeOption option,
  }) async {
    if (option.mode == TaroResizeMode.skip) {
      // do nothing
      return (
        bytes: bytes,
        cotentType: contentType,
      );
    }

    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      return throw TaroResizeException(
        exception: Exception('Failed to decode image.'),
      );
    }

    final decodeMaxWidth = min(option.maxWidth ?? 0, originalImage.width);
    final decodeMaxHeight = min(option.maxHeight ?? 0, originalImage.height);
    if (decodeMaxWidth == originalImage.width &&
        decodeMaxHeight == originalImage.height) {
      // do nothing
      return (
        bytes: bytes,
        cotentType: contentType,
      );
    }

    final cmd = img.Command()
      ..image(originalImage)
      ..copyResize(
        width: decodeMaxWidth,
        height: decodeMaxHeight,
      );
    if (option.mode == TaroResizeMode.original) {
      // do nothing
    } else if (option.mode == TaroResizeMode.png) {
      cmd.encodePng();
    } else if (option.mode == TaroResizeMode.jpg) {
      cmd.encodeJpg();
    }

    final Uint8List? result;
    try {
      result = await cmd.getBytesThread();
    } on Exception catch (exception) {
      throw TaroResizeException(
        exception: exception,
      );
    }

    if (result == null) {
      throw TaroResizeException(
        exception: Exception('Failed to resize image.'),
      );
    }

    return (
      bytes: result,
      cotentType: switch (option.mode) {
        TaroResizeMode.skip || TaroResizeMode.original => contentType,
        TaroResizeMode.png => 'image/png',
        TaroResizeMode.jpg => 'image/jpeg',
      },
    );
  }
}
