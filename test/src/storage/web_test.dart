@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_loader_storage.dart';

void main() {
  group('TaroLoaderStorage on web', () {
    const loader = TaroLoaderStorage();

    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    const contentType = 'image/png';

    test('save and load', () async {
      const url = 'https://example.com/web_save_and_load.png';

      await loader.save(
        url: url,
        bytes: bytes,
        contentType: contentType,
        expireAt: null,
      );

      final loadedBytes = await loader.load(url: url);
      expect(loadedBytes, equals(bytes));
    });

    test('load returns null if the cache entry does not exist', () async {
      const url = 'https://example.com/web_missing.png';

      final loadedBytes = await loader.load(url: url);
      expect(loadedBytes, isNull);
    });

    test('load returns null if expired', () async {
      const url = 'https://example.com/web_expired.png';

      final now = DateTime(2023, 1, 1);
      await withClock(Clock.fixed(now), () async {
        await loader.save(
          url: url,
          bytes: bytes,
          contentType: contentType,
          expireAt: now.add(const Duration(hours: 1)),
        );
      });

      await withClock(Clock.fixed(now.add(const Duration(hours: 2))), () async {
        final loadedBytes = await loader.load(url: url);
        expect(loadedBytes, isNull);
      });

      // The expired entry is deleted, so a second load also misses.
      expect(await loader.load(url: url), isNull);
    });

    test('load returns bytes if not expired', () async {
      const url = 'https://example.com/web_not_expired.png';

      final now = DateTime(2023, 1, 1);
      await withClock(Clock.fixed(now), () async {
        await loader.save(
          url: url,
          bytes: bytes,
          contentType: contentType,
          expireAt: now.add(const Duration(hours: 2)),
        );
      });

      await withClock(Clock.fixed(now.add(const Duration(hours: 1))), () async {
        final loadedBytes = await loader.load(url: url);
        expect(loadedBytes, equals(bytes));
      });
    });
  });
}
