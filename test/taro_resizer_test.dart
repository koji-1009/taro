import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:taro/src/taro_resizer.dart';
import 'package:taro/src/taro_type.dart';

void main() {
  group('TaroResizer', () {
    const resizer = TaroResizer();

    // Create a valid 10x10 red PNG image
    late Uint8List validPng;

    setUp(() {
      final image = img.Image(width: 10, height: 10);
      image.clear(img.ColorRgb8(255, 0, 0)); // Fill with red
      validPng = Uint8List.fromList(img.encodePng(image));
    });

    test('skip option - returns original bytes', () async {
      const option = TaroResizeOptionSkip();
      final result = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: option,
      );

      expect(result.bytes, equals(validPng));
      expect(result.contentType, equals('image/png'));
    });

    test('memory option - returns original bytes', () async {
      const option = TaroResizeOptionMemory(
        maxWidth: 100,
        maxHeight: 100,
      );
      final result = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: option,
      );

      expect(result.bytes, equals(validPng));
      expect(result.contentType, equals('image/png'));
    });

    test('disk option - original format when already smaller', () async {
      const option = TaroResizeOptionDisk(
        format: TaroResizeFormat.original,
        maxWidth: 100,
        maxHeight: 100,
      );
      final result = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: option,
      );

      // Should return original since image is already 10x10
      expect(result.bytes, equals(validPng));
      expect(result.contentType, equals('image/png'));
    });

    test('disk option - resizes and converts to jpeg format', () async {
      const option = TaroResizeOptionDisk(
        format: TaroResizeFormat.jpeg,
        maxWidth: 5, // Force resize
        maxHeight: 5,
      );
      final result = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: option,
      );

      expect(result.contentType, equals('image/jpeg'));
      expect(result.bytes, isNotEmpty);
      expect(result.bytes, isNot(equals(validPng)));
    });

    test('disk option - throws exception on invalid image data', () async {
      const option = TaroResizeOptionDisk(
        format: TaroResizeFormat.png,
      );

      expect(
        () async => await resizer.resizeIfNeeded(
          bytes: Uint8List.fromList([0x00, 0x01, 0x02]), // invalid
          contentType: 'image/png',
          resizeOption: option,
        ),
        throwsA(anything),
      );
    });

    test('disk option - respects maxWidth and maxHeight independently',
        () async {
      // Test maxWidth only
      const optionWidth = TaroResizeOptionDisk(
        format: TaroResizeFormat.png,
        maxWidth: 5,
      );
      final resultWidth = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: optionWidth,
      );

      expect(resultWidth.bytes, isNot(equals(validPng)));

      // Test maxHeight only
      const optionHeight = TaroResizeOptionDisk(
        format: TaroResizeFormat.png,
        maxHeight: 5,
      );
      final resultHeight = await resizer.resizeIfNeeded(
        bytes: validPng,
        contentType: 'image/png',
        resizeOption: optionHeight,
      );

      expect(resultHeight.bytes, isNot(equals(validPng)));
    });
  });
}
