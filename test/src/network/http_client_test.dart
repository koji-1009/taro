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

    test('get aborts the request when the body stalls', () async {
      // A raw socket server, so the test can see the client disconnect.
      final serverSocket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(serverSocket.close);

      final connectionClosed = Completer<void>();
      serverSocket.listen((socket) {
        var responded = false;
        // Both onError and onDone can be called for one disconnect.
        void closed() {
          if (!connectionClosed.isCompleted) {
            connectionClosed.complete();
          }
          socket.destroy();
        }

        socket.listen(
          (_) {
            if (responded) {
              return;
            }
            responded = true;
            // Send the headers and part of the body, then stall.
            socket
              ..write('HTTP/1.1 200 OK\r\nContent-Length: 4\r\n\r\n')
              ..add([1, 2]);
          },
          onDone: closed,
          onError: (Object _) => closed(),
        );
      });
      final uri = Uri.parse(
        'http://${serverSocket.address.address}:${serverSocket.port}/image',
      );

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
      await expectLater(
        connectionClosed.future.timeout(const Duration(seconds: 5)),
        completes,
      );
    });

    test('get returns a chunked body without a content length', () async {
      final uri = await serve((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..bufferOutput = false
          ..add([1, 2]);
        await request.response.flush();
        request.response.add([3, 4]);
        await request.response.close();
      });

      const client = HttpClient();
      final response = await client.get(
        uri: uri,
        headers: const {},
      );

      expect(response.contentLength, equals(4));
      expect(response.bodyBytes, equals([1, 2, 3, 4]));
    });

    test('get returns a decompressed gzip body with a content length',
        () async {
      final body = List<int>.generate(10000, (i) => i % 256);
      final compressed = gzip.encode(body);
      final uri = await serve((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.set(HttpHeaders.contentEncodingHeader, 'gzip')
          ..headers.contentLength = compressed.length
          ..add(compressed);
        await request.response.close();
      });

      const client = HttpClient();
      final response = await client.get(
        uri: uri,
        headers: const {},
      );

      expect(response.contentLength, equals(body.length));
      expect(response.bodyBytes, equals(body));
    });

    test('get does not time out while the body keeps arriving', () async {
      final uri = await serve((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          // Send each part as soon as it is flushed.
          ..bufferOutput = false
          ..headers.contentLength = 5;
        // 5 parts, 60 ms apart: longer than the timeout in total, but each
        // wait is shorter than it.
        for (var i = 0; i < 5; i++) {
          request.response.add([i]);
          await request.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }
        await request.response.close();
      });

      const client = HttpClient(
        timeout: Duration(milliseconds: 200),
      );

      final response = await client.get(
        uri: uri,
        headers: const {},
      );

      expect(response.bodyBytes, equals([0, 1, 2, 3, 4]));
    });
  });
}
