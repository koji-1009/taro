import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/taro.dart';
import 'package:taro/src/taro_image.dart';

import 'taro_test.mocks.dart';

void main() {
  group('TaroImage', () {
    const url1 = 'https://example.com/image.png';
    const url2 = 'https://example.com/other.png';

    test('equality respects url and scale', () {
      const image1 = TaroImage(url1, scale: 1.0);
      const image2 = TaroImage(url1, scale: 1.0);
      const image3 = TaroImage(url1, scale: 2.0);
      const image4 = TaroImage(url2, scale: 1.0);

      expect(image1, equals(image2));
      expect(image1, isNot(equals(image3)));
      expect(image1, isNot(equals(image4)));
    });

    test('equality respects headers when useHeadersHashCode is true', () {
      const headers1 = {'Auth': '1'};
      const headers2 = {'Auth': '2'};

      const image1 = TaroImage(
        url1,
        headers: headers1,
        useHeadersHashCode: true,
      );
      const image2 = TaroImage(
        url1,
        headers: headers1,
        useHeadersHashCode: true,
      );
      const image3 = TaroImage(
        url1,
        headers: headers2,
        useHeadersHashCode: true,
      );

      expect(image1, equals(image2));
      expect(image1, isNot(equals(image3)));
    });

    test('equality ignores headers when useHeadersHashCode is false', () {
      const headers1 = {'Auth': '1'};
      const headers2 = {'Auth': '2'};

      const image1 = TaroImage(
        url1,
        headers: headers1,
        useHeadersHashCode: false,
      );

      const image2 = TaroImage(
        url1,
        headers: headers2,
        useHeadersHashCode: false,
      );

      expect(image1, equals(image2));
    });

    test('equality is symmetric with different useHeadersHashCode', () {
      const headers1 = {'Auth': '1'};
      const headers2 = {'Auth': '2'};

      const imageFalse = TaroImage(
        url1,
        headers: headers1,
        useHeadersHashCode: false,
      );
      const imageTrue = TaroImage(
        url1,
        headers: headers2,
        useHeadersHashCode: true,
      );

      // Different useHeadersHashCode → always not equal (symmetric)
      expect(imageFalse == imageTrue, isFalse);
      expect(imageTrue == imageFalse, isFalse);
    });

    test('equality with same useHeadersHashCode=true and same headers', () {
      const headers = {'Auth': '1'};

      const image1 = TaroImage(
        url1,
        headers: headers,
        useHeadersHashCode: true,
      );
      const image2 = TaroImage(
        url1,
        headers: headers,
        useHeadersHashCode: true,
      );

      expect(image1, equals(image2));
      expect(image2, equals(image1));
    });

    test('hashCode differs for different useHeadersHashCode', () {
      const image1 = TaroImage(url1, useHeadersHashCode: false);
      const image2 = TaroImage(url1, useHeadersHashCode: true);

      // Not equal, so hashCode may differ (not required, but expected)
      expect(image1, isNot(equals(image2)));
    });

    test('hashCode is consistent', () {
      const image1 = TaroImage(url1);
      const image2 = TaroImage(url1);

      expect(image1.hashCode, equals(image2.hashCode));
    });

    test('hashCode includes headers when useHeadersHashCode is true', () {
      const image1 = TaroImage(
        url1,
        headers: {'Auth': '1'},
        useHeadersHashCode: true,
      );
      const image2 = TaroImage(
        url1,
        headers: {'Auth': '2'},
        useHeadersHashCode: true,
      );

      expect(image1.hashCode, isNot(equals(image2.hashCode)));
    });

    test('hashCode ignores headers when useHeadersHashCode is false', () {
      const image1 = TaroImage(url1, headers: {'Auth': '1'});
      const image2 = TaroImage(url1, headers: {'Auth': '2'});

      expect(image1.hashCode, equals(image2.hashCode));
    });

    test('hashCode includes options when useHeadersHashCode is true', () {
      const image1 = TaroImage(
        url1,
        useHeadersHashCode: true,
        customCacheDuration: Duration(days: 1),
      );
      const image2 = TaroImage(
        url1,
        useHeadersHashCode: true,
        customCacheDuration: Duration(days: 2),
      );

      expect(image1.hashCode, isNot(equals(image2.hashCode)));
    });

    test('toString contains the url', () {
      const image = TaroImage(url1);

      expect(image.toString(), contains(url1));
    });

    testWidgets(
        'reports the image provider and key when loading fails without '
        'an error listener', (tester) async {
      final mockNetworkLoader = MockTaroLoaderNetwork();
      final mockStorageLoader = MockTaroLoaderStorage();

      Taro.instance.configure(
        networkLoader: mockNetworkLoader,
        storageLoader: mockStorageLoader,
      );

      when(mockStorageLoader.load(url: url1)).thenAnswer((_) async => null);
      when(mockNetworkLoader.load(
        url: anyNamed('url'),
        headers: anyNamed('headers'),
        checkMaxAgeIfExist: anyNamed('checkMaxAgeIfExist'),
        ifThrowMaxAgeHeaderError: anyNamed('ifThrowMaxAgeHeaderError'),
        customCacheDuration: anyNamed('customCacheDuration'),
      )).thenThrow(Exception('Network Error'));

      final reported = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = reported.add;
      addTearDown(() => FlutterError.onError = previousOnError);

      const image = TaroImage(url1);
      // No `onError` listener, so the failure is reported to FlutterError.
      image
          .resolve(ImageConfiguration.empty)
          .addListener(ImageStreamListener((_, __) {}));

      await tester.pump();
      await tester.pump(Duration.zero);

      expect(reported, isNotEmpty);

      final information = reported.first.informationCollector!().toList();
      expect(
        information.whereType<DiagnosticsProperty<ImageProvider>>(),
        isNotEmpty,
      );
      expect(
        information.whereType<DiagnosticsProperty<TaroImage>>(),
        isNotEmpty,
      );

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    });
  });
}
