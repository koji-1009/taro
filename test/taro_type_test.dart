import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_type.dart';

void main() {
  group('TaroResizeOption', () {
    group('TaroResizeOptionSkip', () {
      test('equality', () {
        const option1 = TaroResizeOptionSkip();
        const option2 = TaroResizeOptionSkip();

        expect(option1, equals(option2));
        expect(option1.hashCode, equals(option2.hashCode));
      });

      test('toString', () {
        const option = TaroResizeOptionSkip();
        expect(option.toString(), equals('skip'));
      });
    });

    group('TaroResizeOptionMemory', () {
      test('equality', () {
        const option1 = TaroResizeOptionMemory(
          maxWidth: 100,
          maxHeight: 200,
        );
        const option2 = TaroResizeOptionMemory(
          maxWidth: 100,
          maxHeight: 200,
        );
        const option3 = TaroResizeOptionMemory(
          maxWidth: 150,
          maxHeight: 200,
        );

        expect(option1, equals(option2));
        expect(option1.hashCode, equals(option2.hashCode));
        expect(option1, isNot(equals(option3)));
      });

      test('toString', () {
        const option = TaroResizeOptionMemory(
          maxWidth: 100,
          maxHeight: 200,
        );
        expect(option.toString(), equals('memory_100x200'));
      });
    });

    group('TaroResizeOptionDisk', () {
      test('equality - same values', () {
        const option1 = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
          maxWidth: 100,
          maxHeight: 200,
        );
        const option2 = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
          maxWidth: 100,
          maxHeight: 200,
        );

        expect(option1, equals(option2));
        expect(option1.hashCode, equals(option2.hashCode));
      });

      test('equality - different format', () {
        const option1 = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
          maxWidth: 100,
          maxHeight: 200,
        );
        const option2 = TaroResizeOptionDisk(
          format: TaroResizeFormat.jpeg,
          maxWidth: 100,
          maxHeight: 200,
        );

        expect(option1, isNot(equals(option2)));
      });

      test('equality - null dimensions', () {
        const option1 = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
        );
        const option2 = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
        );

        expect(option1, equals(option2));
        expect(option1.hashCode, equals(option2.hashCode));
      });

      test('toString with dimensions', () {
        const option = TaroResizeOptionDisk(
          format: TaroResizeFormat.png,
          maxWidth: 100,
          maxHeight: 200,
        );
        expect(option.toString(), equals('disk_png_100x200'));
      });

      test('toString with null dimensions', () {
        const option = TaroResizeOptionDisk(
          format: TaroResizeFormat.jpeg,
        );
        expect(option.toString(), equals('disk_jpeg_autoxauto'));
      });
    });
  });

  group('TaroHeaderOption', () {
    test('default values', () {
      const option = TaroHeaderOption();

      expect(option.checkMaxAgeIfExist, isFalse);
      expect(option.ifThrowMaxAgeHeaderError, isFalse);
      expect(option.customCacheDuration, isNull);
    });

    test('custom values', () {
      const option = TaroHeaderOption(
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: true,
        customCacheDuration: Duration(days: 7),
      );

      expect(option.checkMaxAgeIfExist, isTrue);
      expect(option.ifThrowMaxAgeHeaderError, isTrue);
      expect(option.customCacheDuration, equals(const Duration(days: 7)));
    });

    test('equality', () {
      const option1 = TaroHeaderOption(
        checkMaxAgeIfExist: true,
        customCacheDuration: Duration(days: 7),
      );
      const option2 = TaroHeaderOption(
        checkMaxAgeIfExist: true,
        customCacheDuration: Duration(days: 7),
      );
      const option3 = TaroHeaderOption(
        customCacheDuration: Duration(days: 14),
      );

      expect(option1, equals(option2));
      expect(option1.hashCode, equals(option2.hashCode));
      expect(option1, isNot(equals(option3)));
    });

    test('toString', () {
      const option = TaroHeaderOption(
        checkMaxAgeIfExist: true,
        customCacheDuration: Duration(days: 7),
      );

      final string = option.toString();
      expect(string, contains('TaroHeaderOption'));
      expect(string, contains('checkMaxAgeIfExist: true'));
      expect(string, contains('customCacheDuration: 168:00:00.000000'));
    });
  });
}
