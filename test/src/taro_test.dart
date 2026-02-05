import 'dart:typed_data';

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
