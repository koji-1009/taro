import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:taro/src/taro_loader_storage.dart';

import 'mock_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPathProviderPlatform mockPathProviderPlatform;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('taro_test_');
    mockPathProviderPlatform = MockPathProviderPlatform(tempDir.path);
    PathProviderPlatform.instance = mockPathProviderPlatform;
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('TaroLoaderStorage', () {
    const loader = TaroLoaderStorage();
    const url = 'https://example.com/image.png';

    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    const contentType = 'image/png';

    test('save and load', () async {
      await loader.save(
        url: url,
        bytes: bytes,
        contentType: contentType,
        expireAt: null,
      );

      final loadedBytes = await loader.load(url: url);
      expect(loadedBytes, equals(bytes));
    });

    test('load returns null if file does not exist', () async {
      final loadedBytes = await loader.load(url: url);
      expect(loadedBytes, isNull);
    });

    test('load returns null if expired', () async {
      final now = DateTime(2023, 1, 1);
      final expireAt = now.add(const Duration(hours: 1));

      await withClock(Clock.fixed(now), () async {
        await loader.save(
          url: url,
          bytes: bytes,
          contentType: contentType,
          expireAt: expireAt,
        );
      });

      final futureTime = now.add(const Duration(hours: 2));
      await withClock(Clock.fixed(futureTime), () async {
        final loadedBytes = await loader.load(url: url);
        expect(loadedBytes, isNull);
      });
    });

    test('load returns bytes if not expired', () async {
      final now = DateTime(2023, 1, 1);
      final expireAt = now.add(const Duration(hours: 2));

      await withClock(Clock.fixed(now), () async {
        await loader.save(
          url: url,
          bytes: bytes,
          contentType: contentType,
          expireAt: expireAt,
        );
      });

      final futureTime = now.add(const Duration(hours: 1));
      await withClock(Clock.fixed(futureTime), () async {
        final loadedBytes = await loader.load(url: url);
        expect(loadedBytes, equals(bytes));
      });
    });
  });
}
