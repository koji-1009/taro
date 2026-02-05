import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/storage/cache_file_info.dart';

void main() {
  group('CacheFileInfo', () {
    test('toJson and fromJson round-trip', () {
      final expireAt = DateTime.utc(2024, 6, 15, 12, 30, 0);
      final original = CacheFileInfo(
        contentType: 'image/png',
        expireAt: expireAt,
      );

      final json = original.toJson();
      final restored = CacheFileInfo.fromJson(json);

      expect(restored.contentType, equals('image/png'));
      expect(restored.expireAt, equals(expireAt));
    });

    test('toJson and fromJson with null expireAt', () {
      const original = CacheFileInfo(
        contentType: 'application/json',
        expireAt: null,
      );

      final json = original.toJson();
      final restored = CacheFileInfo.fromJson(json);

      expect(restored.contentType, equals('application/json'));
      expect(restored.expireAt, isNull);
    });

    test('toJson format', () {
      final expireAt = DateTime.utc(2024, 1, 1, 0, 0, 0);
      final info = CacheFileInfo(
        contentType: 'text/plain',
        expireAt: expireAt,
      );

      final json = info.toJson();

      expect(json, contains('"content_type":"text/plain"'));
      expect(json, contains('"expire_at":"2024-01-01T00:00:00.000Z"'));
    });

    test('toJson with null expireAt produces null value', () {
      const info = CacheFileInfo(
        contentType: 'image/jpeg',
        expireAt: null,
      );

      final json = info.toJson();

      expect(json, contains('"content_type":"image/jpeg"'));
      expect(json, contains('"expire_at":null'));
    });

    test('fromJson handles empty expire_at string', () {
      const json = '{"content_type":"image/gif","expire_at":""}';
      final info = CacheFileInfo.fromJson(json);

      expect(info.contentType, equals('image/gif'));
      expect(info.expireAt, isNull);
    });

    test('expireAt is stored in UTC', () {
      // Create with local time
      final localTime = DateTime(2024, 6, 15, 12, 0, 0);
      final info = CacheFileInfo(
        contentType: 'image/png',
        expireAt: localTime.toUtc(),
      );

      final json = info.toJson();
      final restored = CacheFileInfo.fromJson(json);

      // Should preserve the UTC time
      expect(restored.expireAt?.isUtc, isTrue);
    });

    test('different content types', () {
      const types = [
        'image/png',
        'image/jpeg',
        'image/gif',
        'image/webp',
        'application/octet-stream',
      ];

      for (final type in types) {
        final info = CacheFileInfo(
          contentType: type,
          expireAt: null,
        );

        final restored = CacheFileInfo.fromJson(info.toJson());
        expect(restored.contentType, equals(type));
      }
    });
  });
}
