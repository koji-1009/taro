@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/network/http_client.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';

void main() {
  group('HttpClient on web', () {
    test('has a default timeout of 180 seconds', () {
      const client = HttpClient();

      expect(client.timeout, equals(const Duration(seconds: 180)));
    });

    test('get returns the response body, status and headers', () async {
      const client = HttpClient();

      final response = await client.get(
        uri: Uri.parse('data:image/png;base64,AQIDBA=='),
        headers: const {},
      );

      expect(response.statusCode, equals(200));
      expect(response.bodyBytes, equals([1, 2, 3, 4]));
      expect(response.contentLength, equals(4));
      expect(response.isRedirect, isFalse);
      expect(response.headers['content-type'], equals('image/png'));
    });

    test('get throws an Exception when the fetch fails', () async {
      const client = HttpClient();

      await expectLater(
        client.get(
          // Nothing listens on port 1, so the fetch is rejected.
          uri: Uri.parse('http://127.0.0.1:1/image.png'),
          headers: const {},
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('TaroLoaderNetwork on web', () {
    test('load wraps a failed fetch in TaroNetworkException', () async {
      await expectLater(
        const TaroLoaderNetwork().load(
          url: 'http://127.0.0.1:1/image.png',
          headers: const {},
        ),
        throwsA(isA<TaroNetworkException>()),
      );
    });
  });
}
