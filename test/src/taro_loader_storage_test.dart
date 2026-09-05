@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_storage.dart';

import 'mock_path_provider_platform.dart';

class _ThrowingPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationCachePath() async {
    throw Exception('path_provider failure');
  }
}

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

    test('load deletes the info file and returns null if data file is missing',
        () async {
      await loader.save(
        url: url,
        bytes: bytes,
        contentType: contentType,
        expireAt: null,
      );

      final filename = '${sha256.convert(utf8.encode(url))}';
      final cacheFile = File('${tempDir.path}/taro/$filename');
      final cacheInfoFile = File('${tempDir.path}/taro/$filename.json');

      expect(await cacheInfoFile.exists(), isTrue);
      await cacheFile.delete();

      final loadedBytes = await loader.load(url: url);

      expect(loadedBytes, isNull);
      expect(await cacheInfoFile.exists(), isFalse);
    });

    test('load wraps a corrupted cache info file in TaroStorageException',
        () async {
      await loader.save(
        url: url,
        bytes: bytes,
        contentType: contentType,
        expireAt: null,
      );

      final filename = '${sha256.convert(utf8.encode(url))}';
      await File('${tempDir.path}/taro/$filename.json')
          .writeAsString('{"content_type": 1}');

      expect(
        () => loader.load(url: url),
        throwsA(isA<TaroStorageException>()),
      );
    });

    test('load wraps storage errors in TaroStorageException', () async {
      PathProviderPlatform.instance = _ThrowingPathProviderPlatform();

      expect(
        () => loader.load(url: url),
        throwsA(isA<TaroStorageException>()),
      );
    });

    test('save wraps storage errors in TaroStorageException', () async {
      PathProviderPlatform.instance = _ThrowingPathProviderPlatform();

      expect(
        () => loader.save(
          url: url,
          bytes: bytes,
          contentType: contentType,
          expireAt: null,
        ),
        throwsA(isA<TaroStorageException>()),
      );
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
