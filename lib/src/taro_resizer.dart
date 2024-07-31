import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_type.dart';

/// The [TaroResizer] class is used to resize images.
class TaroResizer {
  /// Creates a [TaroResizer].
  const TaroResizer();

  /// Resize the image if needed.
  Future<({Uint8List bytes, String contentType})> resizeIfNeeded({
    required Uint8List bytes,
    required String contentType,
    required TaroResizeOption resizeOption,
  }) async {
    if (resizeOption.mode case TaroResizeMode.skip || TaroResizeMode.memory) {
      // do nothing
      return (
        bytes: bytes,
        contentType: contentType,
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
        contentType: contentType,
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
      throw const TaroResizeFailedException();
    }

    return (
      bytes: result,
      contentType: encodeImageType,
    );
  }
}
