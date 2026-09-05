@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/network/http_client.dart';

void main() {
  group('HttpClient', () {
    HttpServer? server;

    tearDown(() async {
      await server?.close(force: true);
      server = null;
    });

    Future<Uri> serve(
      Future<void> Function(HttpRequest request) handler,
    ) async {
      final boundServer =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server = boundServer;
      unawaited(
        boundServer.forEach(handler).catchError((Object _) {}),
      );

      return Uri.parse(
        'http://${boundServer.address.address}:${boundServer.port}/image',
      );
    }

    test('has a default timeout of 180 seconds', () {
      const client = HttpClient();

      expect(client.timeout, equals(const Duration(seconds: 180)));
    });

    test('get returns the response body, status and headers', () async {
      final receivedHeaders = <String, String>{};

      final uri = await serve((request) async {
        request.headers.forEach((key, values) {
          receivedHeaders[key] = values.join(',');
        });

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType('image', 'png')
          ..headers.set('cache-control', 'max-age=100')
          ..headers.contentLength = 4
          ..add([1, 2, 3, 4]);
        await request.response.close();
      });

      const client = HttpClient();
      final response = await client.get(
        uri: uri,
        headers: const {'x-taro': 'value'},
      );

      expect(response.statusCode, equals(200));
      expect(response.bodyBytes, equals([1, 2, 3, 4]));
      expect(response.contentLength, equals(4));
      expect(response.isRedirect, isFalse);
      expect(response.headers['content-type'], equals('image/png'));
      expect(response.headers['cache-control'], equals('max-age=100'));
      expect(receivedHeaders['x-taro'], equals('value'));
    });

    test('get exposes the reason phrase of an error response', () async {
      final uri = await serve((request) async {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      });

      const client = HttpClient();
      final response = await client.get(
        uri: uri,
        headers: const {},
      );

      expect(response.statusCode, equals(404));
      expect(response.reasonPhrase, equals('Not Found'));
    });

    test('get throws TimeoutException when the response is too slow', () async {
      final completer = Completer<void>();
      final uri = await serve((request) async {
        // Never respond until the test is done.
        await completer.future;
        await request.response.close();
      });

      const client = HttpClient(
        timeout: Duration(milliseconds: 100),
      );

      await expectLater(
        client.get(
          uri: uri,
          headers: const {},
        ),
        throwsA(isA<TimeoutException>()),
      );

      completer.complete();
    });
  });
}
