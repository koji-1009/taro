import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';

@GenerateNiceMocks([
  MockSpec<TaroHttpClient>(),
])
import 'taro_loader_network_test.mocks.dart';

void main() {
  final mockHttpClient = MockTaroHttpClient();

  final loader = TaroLoaderNetwork(
    client: mockHttpClient,
  );

  final bodyBytes = Uint8List(100);

  const contentType = 'image/jpeg';

  test('load success status code: 200', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 200,
        bodyBytes: bodyBytes,
        reasonPhrase: null,
        contentLength: bodyBytes.length,
        headers: {
          'content-type': contentType,
        },
        isRedirect: false,
      ),
    );

    final result = await loader.load(
      url: url,
      headers: const {},
    );

    expect(
      result,
      equals(
        (
          bytes: bodyBytes,
          contentType: contentType,
          expireAt: null,
        ),
      ),
    );
  });

  test('load success status code: 200 (ignore cache-control)', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 200,
        bodyBytes: bodyBytes,
        reasonPhrase: null,
        contentLength: bodyBytes.length,
        headers: {
          'content-type': contentType,
          'cache-control': 'max-age=100',
        },
        isRedirect: false,
      ),
    );

    final result = await loader.load(
      url: url,
      headers: const {},
    );

    expect(
      result,
      equals(
        (
          bytes: bodyBytes,
          contentType: contentType,
          expireAt: null,
        ),
      ),
    );
  });

  test('load success status code: 200 (check cache-control)', () async {
    await withClock(Clock.fixed(DateTime(2024)), () async {
      const url = 'https://example.com';

      when(mockHttpClient.get(
        uri: Uri.parse(url),
        headers: const {},
      )).thenAnswer(
        (_) async => TaroHttpResponse(
          statusCode: 200,
          bodyBytes: bodyBytes,
          reasonPhrase: null,
          contentLength: bodyBytes.length,
          headers: {
            'content-type': contentType,
            'cache-control': 'max-age=100',
          },
          isRedirect: false,
        ),
      );

      final result = await loader.load(
        url: url,
        headers: const {},
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: true,
      );

      expect(
        result,
        equals(
          (
            bytes: bodyBytes,
            contentType: contentType,
            expireAt: clock.now().add(const Duration(seconds: 100)),
          ),
        ),
      );
    });
  });

  test('load invalid uri', () async {
    const url = 'example.com';

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
        );
        fail('should throw TaroUriInvalidException');
      },
      throwsA(isA<TaroUriParseException>()),
    );
  });

  test('load network error', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenThrow(
      const SocketException(
        'SocketException: Failed host lookup: \'example.com\' (OS Error: nodename nor servname provided, or not known, errno = 8)',
      ),
    );

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
        );
        fail('should throw TaroNetworkException');
      },
      throwsA(isA<TaroNetworkException>()),
    );
  });

  test('load response error 400', () async {
    const url = 'https://example.com';
    final emptyBodyBytes = Uint8List(0);

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 400,
        bodyBytes: emptyBodyBytes,
        reasonPhrase: 'Bad Request',
        contentLength: emptyBodyBytes.length,
        headers: const <String, String>{},
        isRedirect: false,
      ),
    );

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
        );
        fail('should throw TaroHttpResponseException');
      },
      throwsA(isA<TaroHttpResponseException>()),
    );
  });

  test('load response error 400 (no reason phrase)', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 400,
        bodyBytes: Uint8List(0),
        reasonPhrase: null,
        contentLength: 0,
        headers: const <String, String>{},
        isRedirect: false,
      ),
    );

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
        );
        fail('should throw TaroHttpResponseException');
      },
      throwsA(isA<TaroHttpResponseException>()),
    );
  });

  test('empty body response', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 200,
        bodyBytes: Uint8List(0),
        reasonPhrase: null,
        contentLength: 0,
        headers: {
          'content-type': contentType,
        },
        isRedirect: false,
      ),
    );

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
        );
        fail('should throw TaroEmptyResponseException');
      },
      throwsA(isA<TaroEmptyResponseException>()),
    );
  });

  test('invalid cache-control header (abort exception)', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 200,
        bodyBytes: bodyBytes,
        reasonPhrase: null,
        contentLength: bodyBytes.length,
        headers: <String, String>{
          'content-type': contentType,
          'cache-control': 'max-age=abc',
        },
        isRedirect: false,
      ),
    );

    final result = await loader.load(
      url: url,
      headers: const {},
      checkMaxAgeIfExist: true,
    );

    expect(
      result,
      equals(
        (
          bytes: bodyBytes,
          contentType: contentType,
          expireAt: null,
        ),
      ),
    );
  });

  test('invalid cache-control header', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => TaroHttpResponse(
        statusCode: 200,
        bodyBytes: bodyBytes,
        reasonPhrase: null,
        contentLength: bodyBytes.length,
        headers: <String, String>{
          'cache-control': 'max-age=abc',
        },
        isRedirect: false,
      ),
    );

    expect(
      () async {
        await loader.load(
          url: url,
          headers: const {},
          checkMaxAgeIfExist: true,
          ifThrowMaxAgeHeaderError: true,
        );
        fail('should throw TaroNetworkException');
      },
      throwsA(isA<TaroNetworkException>()),
    );
  });

  test('custom cache duration (7 days)', () async {
    const url = 'https://example.com';
    final now = DateTime(2024, 1, 1, 12, 0, 0);

    await withClock(Clock.fixed(now), () async {
      when(mockHttpClient.get(
        uri: Uri.parse(url),
        headers: const {},
      )).thenAnswer(
        (_) async => TaroHttpResponse(
          statusCode: 200,
          bodyBytes: bodyBytes,
          reasonPhrase: null,
          contentLength: bodyBytes.length,
          headers: {
            'content-type': contentType,
          },
          isRedirect: false,
        ),
      );

      final result = await loader.load(
        url: url,
        headers: const {},
        customCacheDuration: const Duration(days: 7),
      );

      expect(result?.expireAt, equals(now.add(const Duration(days: 7))));
    });
  });

  test('custom cache duration overrides cache-control header', () async {
    const url = 'https://example.com';
    final now = DateTime(2024, 1, 1, 12, 0, 0);

    await withClock(Clock.fixed(now), () async {
      when(mockHttpClient.get(
        uri: Uri.parse(url),
        headers: const {},
      )).thenAnswer(
        (_) async => TaroHttpResponse(
          statusCode: 200,
          bodyBytes: bodyBytes,
          reasonPhrase: null,
          contentLength: bodyBytes.length,
          headers: {
            'content-type': contentType,
            'cache-control': 'max-age=3600', // 1 hour
          },
          isRedirect: false,
        ),
      );

      final result = await loader.load(
        url: url,
        headers: const {},
        checkMaxAgeIfExist: true,
        customCacheDuration: const Duration(days: 7), // should override
      );

      // Should use custom duration (7 days), not cache-control (1 hour)
      expect(result?.expireAt, equals(now.add(const Duration(days: 7))));
    });
  });
}
