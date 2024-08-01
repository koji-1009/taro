import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taro/src/network/http_client.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_loader_network.dart';
import 'package:taro/src/taro_resizer.dart';
import 'package:taro/src/taro_type.dart';

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<TaroResizer>(),
])
import 'taro_loader_network_test.mocks.dart';

void main() {
  final mockHttpClient = MockHttpClient();
  final mockTaroResizer = MockTaroResizer();

  final loader = TaroLoaderNetwork(
    client: mockHttpClient,
    resizer: mockTaroResizer,
  );

  final bodyBytes = Uint8List(100);
  const resizeOption = TaroResizeOptionSkip();
  const headerOption = (
    checkMaxAgeIfExist: false,
    ifThrowMaxAgeHeaderError: false,
  );

  const contentType = 'image/jpeg';

  test('load success status code: 200', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => (
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
    when(mockTaroResizer.resizeIfNeeded(
      bytes: bodyBytes,
      contentType: contentType,
      resizeOption: resizeOption,
    )).thenAnswer(
      (_) async => (
        bytes: bodyBytes,
        contentType: contentType,
      ),
    );

    final result = await loader.load(
      url: url,
      headers: const {},
      resizeOption: resizeOption,
      headerOption: headerOption,
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
      (_) async => (
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
    when(mockTaroResizer.resizeIfNeeded(
      bytes: bodyBytes,
      contentType: contentType,
      resizeOption: resizeOption,
    )).thenAnswer(
      (_) async => (
        bytes: bodyBytes,
        contentType: contentType,
      ),
    );

    final result = await loader.load(
      url: url,
      headers: const {},
      resizeOption: resizeOption,
      headerOption: headerOption,
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
        (_) async => (
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
      when(mockTaroResizer.resizeIfNeeded(
        bytes: bodyBytes,
        contentType: contentType,
        resizeOption: resizeOption,
      )).thenAnswer(
        (_) async => (
          bytes: bodyBytes,
          contentType: contentType,
        ),
      );

      final result = await loader.load(
        url: url,
        headers: const {},
        resizeOption: resizeOption,
        headerOption: (
          checkMaxAgeIfExist: true,
          ifThrowMaxAgeHeaderError: true,
        ),
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
          resizeOption: resizeOption,
          headerOption: headerOption,
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
          resizeOption: resizeOption,
          headerOption: headerOption,
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
      (_) async => (
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
          resizeOption: resizeOption,
          headerOption: headerOption,
        );
        fail('should throw TaroHttpResponseException');
      },
      throwsA(isA<TaroHttpResponseException>()),
    );
  });

  test('load response error 400', () async {
    const url = 'https://example.com';

    when(mockHttpClient.get(
      uri: Uri.parse(url),
      headers: const {},
    )).thenAnswer(
      (_) async => (
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
          resizeOption: resizeOption,
          headerOption: headerOption,
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
      (_) async => (
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
          resizeOption: resizeOption,
          headerOption: headerOption,
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
      (_) async => (
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
      resizeOption: resizeOption,
      headerOption: (
        checkMaxAgeIfExist: true,
        ifThrowMaxAgeHeaderError: false,
      ),
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
      (_) async => (
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
          resizeOption: resizeOption,
          headerOption: (
            checkMaxAgeIfExist: true,
            ifThrowMaxAgeHeaderError: true,
          ),
        );
        fail('should throw TaroNetworkException');
      },
      throwsA(isA<TaroNetworkException>()),
    );
  });
}
