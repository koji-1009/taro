import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:taro/src/taro_exception.dart';

/// The [TaroResizeMode] enum is used to determine how images are resized.
/// Please refer to [https://pub.dev/packages/image] for supported formats.
enum TaroResizeMode {
  /// The image is not resized.
  skip,

  /// The image is resized to the original contentType.
  original,

  /// The image is resized to a gif.
  gif,

  /// The image is resized to a jpg.
  jpeg,

  /// The image is resized to a png.
  png,

  /// The image is resized to a bmp.
  bmp,

  /// The image is resized to a ico.
  ico,

  /// The image is resized to a tiff.
  tiff,
}

/// The [TaroResizeOption] class is used to throw exceptions when resizing images.
typedef TaroResizeOption = ({
  /// The resize mode of the image.
  TaroResizeMode mode,

  /// The maximum width of the image. If null, the width is not limited.
  int? maxWidth,

  /// The maximum height of the image. If null, the height is not limited.
  int? maxHeight,
});

/// The [TaroResizer] class is used to resize images.
class TaroResizer {
  TaroResizer._();

  /// Resize the image if needed.
  static Future<({Uint8List bytes, String cotentType})> resizeIfNeeded({
    required Uint8List bytes,
    required String contentType,
    required TaroResizeOption resizeOption,
  }) async {
    if (resizeOption.mode == TaroResizeMode.skip) {
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

    final int maxWidth;
    if (resizeOption.maxWidth != null) {
      maxWidth = min(resizeOption.maxWidth!, originalImage.width);
    } else {
      maxWidth = originalImage.width;
    }

    final int maxHeight;
    if (resizeOption.maxHeight != null) {
      maxHeight = min(resizeOption.maxHeight!, originalImage.height);
    } else {
      maxHeight = originalImage.height;
    }

    if (maxWidth == originalImage.width && maxHeight == originalImage.height) {
      return (
        bytes: bytes,
        cotentType: contentType,
      );
    }

    final cmd = img.Command()
      ..image(originalImage)
      ..copyResize(
        width: maxWidth,
        height: maxHeight,
      );

    final String encodeImageType;
    switch (resizeOption.mode) {
      case TaroResizeMode.skip:
        // this case is not possible
        throw Exception('This case is not possible.');
      case TaroResizeMode.original:
        switch (contentType) {
          case 'image/gif':
          case 'image/jpeg':
          case 'image/png':
          case 'image/bmp':
          case 'image/x-icon':
          case 'image/tiff':
            encodeImageType = contentType;
          default:
            encodeImageType = 'image/png';
        }
      case TaroResizeMode.gif:
        encodeImageType = 'image/gif';
      case TaroResizeMode.jpeg:
        encodeImageType = 'image/jpeg';
      case TaroResizeMode.png:
        encodeImageType = 'image/png';
      case TaroResizeMode.bmp:
        encodeImageType = 'image/bmp';
      case TaroResizeMode.ico:
        encodeImageType = 'image/x-icon';
      case TaroResizeMode.tiff:
        encodeImageType = 'image/tiff';
      default:
        encodeImageType = 'image/png';
    }

    switch (encodeImageType) {
      case 'image/gif':
        cmd.encodeGif();
      case 'image/jpeg':
        cmd.encodeJpg();
      case 'image/png':
        cmd.encodePng();
      case 'image/bmp':
        cmd.encodeBmp();
      case 'image/x-icon':
        cmd.encodeIco();
      case 'image/tiff':
        cmd.encodeTiff();
      default:
        // if the contentType is not supported, encode the image to png
        cmd.encodePng();
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
      cotentType: encodeImageType,
    );
  }
}
