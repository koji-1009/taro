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
    switch (resizeOption) {
      case TaroResizeOptionSkip() || TaroResizeOptionMemory():
        // do nothing
        return (
          bytes: bytes,
          contentType: contentType,
        );
      case TaroResizeOptionDisk(
          format: final optionFormat,
          maxWidth: final optionMaxWidth,
          maxHeight: final optionMaxHeight,
        ):
        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          throw TaroResizeException(
            exception: Exception('Failed to decode image.'),
          );
        }

        final int maxWidth;
        if (optionMaxWidth != null) {
          maxWidth = min(optionMaxWidth, originalImage.width);
        } else {
          maxWidth = originalImage.width;
        }

        final int maxHeight;
        if (optionMaxHeight != null) {
          maxHeight = min(optionMaxHeight, originalImage.height);
        } else {
          maxHeight = originalImage.height;
        }

        if (maxWidth == originalImage.width &&
            maxHeight == originalImage.height) {
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
        switch (optionFormat) {
          case TaroResizeFormat.original:
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
          case TaroResizeFormat.gif:
            encodeImageType = 'image/gif';
          case TaroResizeFormat.jpeg:
            encodeImageType = 'image/jpeg';
          case TaroResizeFormat.png:
            encodeImageType = 'image/png';
          case TaroResizeFormat.bmp:
            encodeImageType = 'image/bmp';
          case TaroResizeFormat.ico:
            encodeImageType = 'image/x-icon';
          case TaroResizeFormat.tiff:
            encodeImageType = 'image/tiff';
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
}
