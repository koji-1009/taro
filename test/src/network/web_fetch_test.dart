@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/network/web_fetch.dart';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Request]
///
/// `Request` takes the same init dictionary as `fetch`, so it can be used to
/// inspect what the init built by [RequestInit] actually carries.
@JS('Request')
extension type _Request._(JSObject _) implements JSObject {
  external factory _Request(
    String url,
    RequestInit init,
  );

  external _Headers get headers;
}

extension type _Headers._(JSObject _) implements JSObject {
  external String? get(String name);
}

void main() {
  group('RequestInit', () {
    test('carries the headers into the request', () {
      final headers = Headers()
        ..append('x-taro', 'value')
        ..append('authorization', 'Bearer token');

      final request = _Request(
        'https://example.com/image.png',
        RequestInit(
          headers: headers,
        ),
      );

      expect(request.headers.get('x-taro'), equals('value'));
      expect(request.headers.get('authorization'), equals('Bearer token'));
    });
  });
}
