import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_image.dart';

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

    test('hashCode is consistent', () {
      const image1 = TaroImage(url1);
      const image2 = TaroImage(url1);

      expect(image1.hashCode, equals(image2.hashCode));
    });
  });
}
