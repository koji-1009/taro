import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader.dart';

import 'taro_test.mocks.dart';

void main() {
  group('TaroLoader', () {
    late TaroLoader loader;
    late MockTaroLoaderNetwork mockNetworkLoader;
    late MockTaroLoaderStorage mockStorageLoader;

    const url = 'https://example.com/image.png';
    final bytes = Uint8List.fromList([1, 2, 3]);
    const headers = <String, String>{'Auth': 'Token'};

    setUp(() {
      mockNetworkLoader = MockTaroLoaderNetwork();
      mockStorageLoader = MockTaroLoaderStorage();
      loader = TaroLoader();
      loader.changeNetworkLoader(mockNetworkLoader);
      loader.changeStorageLoader(mockStorageLoader);
    });

    tearDown(() {
      reset(mockNetworkLoader);
      reset(mockStorageLoader);
    });

    test('returns storage bytes when storage succeeds', () async {
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => bytes);

      final result = await loader.load(
        url: url,
        headers: headers,
      );

      expect(result, equals(bytes));
      verify(mockStorageLoader.load(url: url)).called(1);
      verifyNever(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      ));
    });

    test('falls back to network when storage returns null', () async {
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (bytes: bytes, contentType: 'image/png', expireAt: null),
      );

      final result = await loader.load(url: url, headers: headers);

      expect(result, equals(bytes));
      verify(mockStorageLoader.load(url: url)).called(1);
      verify(mockNetworkLoader.load(
        url: url,
        headers: headers,
        checkMaxAgeIfExist: false,
        ifThrowMaxAgeHeaderError: false,
        customCacheDuration: null,
      )).called(1);
    });

    test(
        'calls onStorageError and falls back to network on storage load exception',
        () async {
      TaroStorageFailureException? capturedError;
      loader.setOnStorageError((e) => capturedError = e);

      when(mockStorageLoader.load(url: url))
          .thenThrow(Exception('Disk error'));
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (bytes: bytes, contentType: 'image/png', expireAt: null),
      );

      final result = await loader.load(url: url, headers: headers);

      expect(result, equals(bytes));
      expect(capturedError, isNotNull);
      expect(
        capturedError!.operationType,
        equals(TaroStorageOperationType.load),
      );
      expect(capturedError!.url, equals(url));
    });

    test('throws TaroLoadException when network returns null', () async {
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer((_) async => null);

      expect(
        () => loader.load(url: url, headers: headers),
        throwsA(isA<TaroLoadException>()),
      );
    });

    test(
        'calls onStorageError on storage save exception but still returns bytes',
        () async {
      TaroStorageFailureException? capturedError;
      loader.setOnStorageError((e) => capturedError = e);

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (bytes: bytes, contentType: 'image/png', expireAt: null),
      );
      when(mockStorageLoader.save(
        url: anyNamed('url'),
        bytes: anyNamed('bytes'),
        contentType: anyNamed('contentType'),
        expireAt: anyNamed('expireAt'),
      )).thenThrow(Exception('Disk full'));

      final result = await loader.load(url: url, headers: headers);

      expect(result, equals(bytes));
      expect(capturedError, isNotNull);
      expect(
        capturedError!.operationType,
        equals(TaroStorageOperationType.save),
      );
    });

    test('saves to storage after network load', () async {
      final expireAt = DateTime.utc(2024, 6, 1);

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async =>
            (bytes: bytes, contentType: 'image/png', expireAt: expireAt),
      );

      await loader.load(url: url, headers: headers);

      verify(mockStorageLoader.save(
        url: url,
        bytes: bytes,
        contentType: 'image/png',
        expireAt: expireAt,
      )).called(1);
    });

    test('does not call onStorageError when no callback is set', () async {
      when(mockStorageLoader.load(url: url))
          .thenThrow(Exception('Disk error'));
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (bytes: bytes, contentType: 'image/png', expireAt: null),
      );

      // Should not throw even without callback
      final result = await loader.load(url: url, headers: headers);
      expect(result, equals(bytes));
    });
  });
}
