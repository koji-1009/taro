import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_loader_network.dart';

void main() {
  group('TaroHttpResponse', () {
    test('equality', () {
      final response1 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/json'},
      );

      final response2 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/json'},
      );

      final response3 = TaroHttpResponse(
        statusCode: 404,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/json'},
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('hashCode', () {
      final response1 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/json'},
      );

      final response2 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/json'},
      );

      expect(response1.hashCode, equals(response2.hashCode));
    });

    test('header normalization', () {
      final response = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List(0),
        headers: const {
          'Content-Type': 'application/json',
          'CACHE-CONTROL': 'no-cache',
        },
      );

      expect(response.headers['content-type'], equals('application/json'));
      expect(response.headers['cache-control'], equals('no-cache'));
    });

    test('toString', () {
      final response = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: const {'content-type': 'application/octet-stream'},
        reasonPhrase: 'OK',
      );

      final str = response.toString();
      expect(str, contains('statusCode: 200'));
      expect(str, contains('bodyBytes: 3 bytes'));
      expect(str, contains('content-type: application/octet-stream'));
      expect(str, contains('reasonPhrase: OK'));
    });
  });
}
