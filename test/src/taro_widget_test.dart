import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_widget.dart';

import 'taro_test.mocks.dart';

void main() {
  group('TaroWidget', () {
    late MockTaroLoaderNetwork mockNetworkLoader;
    late MockTaroLoaderStorage mockStorageLoader;

    setUp(() {
      mockNetworkLoader = MockTaroLoaderNetwork();
      mockStorageLoader = MockTaroLoaderStorage();

      Taro.instance.configure(
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

    testWidgets('displays placeholder while loading', (tester) async {
      const url = 'https://example.com/image.png';

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);

      final completer = Completer<
          ({Uint8List bytes, String contentType, DateTime? expireAt})?>();

      when(mockNetworkLoader.load(
        url: url,
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: TaroWidget(
            url: url,
            placeholder: (context, url) => const Text('Loading...'),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);

      expect(find.text('Loading...'), findsOneWidget);

      completer.complete((
        bytes: Uint8List.fromList([
          0x47,
          0x49,
          0x46,
          0x38,
          0x39,
          0x61,
          0x01,
          0x00,
          0x01,
          0x00,
          0x80,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x21,
          0xf9,
          0x04,
          0x01,
          0x00,
          0x00,
          0x00,
          0x00,
          0x2c,
          0x00,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x01,
          0x00,
          0x00,
          0x02,
          0x02,
          0x44,
          0x01,
          0x00,
          0x3b
        ]),
        contentType: 'image/gif',
        expireAt: null,
      ));
      await tester.pump();
    });

    testWidgets('displays error builder on failure', (tester) async {
      const url = 'https://example.com/error.png';

      when(mockStorageLoader.load(url: url)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: url,
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenThrow(Exception('Network Error'));

      await tester.pumpWidget(
        MaterialApp(
          home: TaroWidget(
            url: url,
            errorBuilder: (context, url, error, stackTrace) =>
                const Text('Error Occurred'),
          ),
        ),
      );

      // Need to pump to process format exception or image loading error
      await tester.pump();
      await tester.pump(Duration.zero);

      expect(find.text('Error Occurred'), findsOneWidget);
    });
  });
}
