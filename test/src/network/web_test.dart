@TestOn('browser')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/network/http_client.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';

/// A server on the VM that the browser tests talk to. It sends its port first,
/// then 'closed' when the client disconnects.
///
/// - `/hang`: accepts the request and never responds.
/// - `/stall`: sends the headers and part of the body, then stalls.
/// - `/slow`: sends 5 bytes 60 ms apart.
const _serverCode = r'''
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

Future<void> hybridMain(StreamChannel<Object?> channel) async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((socket) {
    var closed = false;
    void close() {
      if (!closed) {
        closed = true;
        channel.sink.add('closed');
      }
      socket.destroy();
    }

    var responded = false;
    socket.listen(
      (data) async {
        if (responded) {
          return;
        }
        responded = true;
        final requestLine = latin1.decode(data).split('\r\n').first;
        const headers = 'HTTP/1.1 200 OK\r\n'
            'Access-Control-Allow-Origin: *\r\n';
        if (requestLine.contains('/stall')) {
          socket
            ..write('${headers}Content-Length: 4\r\n\r\n')
            ..add([1, 2]);
        } else if (requestLine.contains('/slow')) {
          socket.write('${headers}Content-Length: 5\r\n\r\n');
          for (var i = 0; i < 5; i++) {
            socket.add([i]);
            await socket.flush();
            await Future<void>.delayed(const Duration(milliseconds: 60));
          }
        }
      },
      onDone: close,
      onError: (Object _) => close(),
    );
  });
  channel.sink.add(server.port);
}
''';

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

  group('HttpClient on web with a server', () {
    late Stream<dynamic> messages;
    late int port;

    setUp(() async {
      messages = spawnHybridCode(_serverCode).stream.asBroadcastStream();
      // Numbers sent from the hybrid code arrive as double on dart2wasm.
      port = (await messages.first as num).toInt();
    });

    test('get aborts the request when the headers do not arrive', () async {
      final connectionClosed = messages.firstWhere((m) => m == 'closed');

      const client = HttpClient(
        timeout: Duration(milliseconds: 200),
      );

      await expectLater(
        client.get(
          uri: Uri.parse('http://127.0.0.1:$port/hang'),
          headers: const {},
        ),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        connectionClosed.timeout(const Duration(seconds: 5)),
        completes,
      );
    });

    test('get aborts the request when the body stalls', () async {
      final connectionClosed = messages.firstWhere((m) => m == 'closed');

      const client = HttpClient(
        timeout: Duration(milliseconds: 200),
      );

      await expectLater(
        client.get(
          uri: Uri.parse('http://127.0.0.1:$port/stall'),
          headers: const {},
        ),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        connectionClosed.timeout(const Duration(seconds: 5)),
        completes,
      );
    });

    test('get does not time out while the body keeps arriving', () async {
      const client = HttpClient(
        timeout: Duration(milliseconds: 200),
      );

      final response = await client.get(
        uri: Uri.parse('http://127.0.0.1:$port/slow'),
        headers: const {},
      );

      expect(response.bodyBytes, equals([0, 1, 2, 3, 4]));
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
