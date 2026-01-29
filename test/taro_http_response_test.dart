import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_loader_network.dart';

void main() {
  group('TaroHttpResponse', () {
    test('equality', () {
      final response1 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: {'content-type': 'application/json'},
      );

      final response2 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: {'content-type': 'application/json'},
      );

      final response3 = TaroHttpResponse(
        statusCode: 404,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: {'content-type': 'application/json'},
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('hashCode', () {
      final response1 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: {'content-type': 'application/json'},
      );

      final response2 = TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List.fromList([1, 2, 3]),
        headers: {'content-type': 'application/json'},
      );

      expect(response1.hashCode, equals(response2.hashCode));
    });
  });
}
