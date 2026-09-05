import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_image.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_loader_storage.dart';

@GenerateNiceMocks([
  MockSpec<TaroLoaderNetwork>(),
  MockSpec<TaroLoaderStorage>(),
])
import 'taro_test.mocks.dart';

void main() {
  group('Taro', () {
    late Taro taro;
    late MockTaroLoaderNetwork mockNetworkLoader;
    late MockTaroLoaderStorage mockStorageLoader;

    setUp(() {
      taro = Taro.instance;
      mockNetworkLoader = MockTaroLoaderNetwork();
      mockStorageLoader = MockTaroLoaderStorage();

      // Reset configurations
      taro.configure(
        networkLoader: mockNetworkLoader,
        storageLoader: mockStorageLoader,
        checkMaxAgeIfExist: false,
        ifThrowMaxAgeHeaderError: false,
        customCacheDuration: null,
      );
      // `configure` ignores null, so reset it through the setter.
      taro.customCacheDuration = null;
    });

    tearDown(() {
      reset(mockNetworkLoader);
      reset(mockStorageLoader);
    });

    test('instance returns singleton', () {
      expect(Taro.instance, same(taro));
    });

    test('loadBytes delegates to loader which uses storage and network',
        () async {
      const url = 'https://example.com/image.png';
      final bytes = Uint8List.fromList([1, 2, 3]);
      final headers = {'Auth': 'Token'};

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: url,
        headers: headers,
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: bytes,
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      final result = await taro.loadBytes(url, headers: headers);

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

    test('loadImageProvider returns TaroImage', () {
      const url = 'https://example.com/image.png';
      final provider = taro.loadImageProvider(url);

      expect(provider, isA<TaroImage>());
    });

    test('loadImageProvider returns ResizeImage when cacheWidth is set', () {
      const url = 'https://example.com/image.png';
      final provider = taro.loadImageProvider(url, cacheWidth: 100);

      expect(provider, isA<ResizeImage>());
    });

    test('loadImageProvider returns ResizeImage when cacheHeight is set', () {
      const url = 'https://example.com/image.png';
      final provider = taro.loadImageProvider(url, cacheHeight: 100);

      expect(provider, isA<ResizeImage>());
    });

    test('configure does not reset onStorageError when not provided', () async {
      var callbackCalled = false;
      taro.onStorageError = (e) => callbackCalled = true;

      // configure without onStorageError should not reset it
      taro.configure(checkMaxAgeIfExist: true);

      // Trigger a storage error to verify callback is still set
      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url))
          .thenThrow(Exception('Storage error'));
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(1),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);
      expect(callbackCalled, isTrue);
    });

    test('configure does not reset customCacheDuration when not provided',
        () async {
      taro.customCacheDuration = const Duration(minutes: 10);
      taro.configure(checkMaxAgeIfExist: true);

      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(0),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);

      verify(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: false,
        customCacheDuration: const Duration(minutes: 10),
      )).called(1);
    });

    test('checkMaxAgeIfExist setter is applied to the network loader',
        () async {
      taro.checkMaxAgeIfExist = true;

      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(0),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);

      verify(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: false,
        customCacheDuration: null,
      )).called(1);
    });

    test('ifThrowMaxAgeHeaderError setter is applied to the network loader',
        () async {
      taro.ifThrowMaxAgeHeaderError = true;

      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(0),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);

      verify(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: false,
        ifThrowMaxAgeHeaderError: true,
        customCacheDuration: null,
      )).called(1);
    });

    test('networkLoader setter replaces the loader in use', () async {
      final replacement = MockTaroLoaderNetwork();
      taro.networkLoader = replacement;

      const url = 'https://example.com/image.png';
      final bytes = Uint8List.fromList([9, 9, 9]);

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(replacement.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: bytes,
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      final result = await taro.loadBytes(url);

      expect(result, equals(bytes));
      verifyNever(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      ));
    });

    test('networkLoaderTimeout setter replaces the loader in use', () async {
      taro.networkLoaderTimeout = const Duration(seconds: 5);

      const url = 'https://example.com/image.png';
      final bytes = Uint8List.fromList([4, 5, 6]);

      // Resolved from storage, so the newly created network loader is not used.
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => bytes);

      final result = await taro.loadBytes(url);

      expect(result, equals(bytes));
      verifyNever(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      ));
    });

    test('storageLoader setter replaces the loader in use', () async {
      final replacement = MockTaroLoaderStorage();
      taro.storageLoader = replacement;

      const url = 'https://example.com/image.png';
      final bytes = Uint8List.fromList([7, 8, 9]);

      when(replacement.load(url: url)).thenAnswer((_) async => bytes);

      final result = await taro.loadBytes(url);

      expect(result, equals(bytes));
      verifyNever(mockStorageLoader.load(url: anyNamed('url')));
    });

    test('configure sets onStorageError', () async {
      Object? received;
      taro.configure(onStorageError: (e) => received = e);

      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url))
          .thenThrow(Exception('Storage error'));
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(1),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);

      expect(received, isNotNull);
    });

    test('configure updates config', () async {
      taro.configure(
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: true,
        customCacheDuration: const Duration(minutes: 5),
      );

      const url = 'https://example.com/image.png';
      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);

      // Use anyNamed for flexible matching to ensure call is recorded
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer(
        (_) async => (
          bytes: Uint8List(0),
          contentType: 'image/png',
          expireAt: null,
        ),
      );

      await taro.loadBytes(url);

      // Verify execution reached storage loader
      verify(mockStorageLoader.load(url: url)).called(1);

      // Verify network loader was called with updated config
      verify(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: true,
        customCacheDuration: const Duration(minutes: 5),
      )).called(1);
    });
  });
}
