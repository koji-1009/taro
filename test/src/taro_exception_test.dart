import 'package:flutter_test/flutter_test.dart';
import 'package:taro/src/taro_exception.dart';

void main() {
  group('TaroLoadException', () {
    test('toString contains message', () {
      const exception = TaroLoadException(message: 'Test error');
      expect(exception.toString(), contains('TaroLoadException'));
      expect(exception.toString(), contains('Test error'));
    });

    test('message property', () {
      const exception = TaroLoadException(message: 'Failed to load');
      expect(exception.message, equals('Failed to load'));
    });
  });

  group('TaroStorageException', () {
    test('toString contains exception', () {
      final exception = TaroStorageException(
        exception: Exception('Storage error'),
      );
      expect(exception.toString(), contains('TaroStorageException'));
      expect(exception.toString(), contains('Storage error'));
    });

    test('exception property', () {
      final original = Exception('Disk full');
      final exception = TaroStorageException(exception: original);
      expect(exception.exception, equals(original));
    });
  });

  group('TaroUriParseException', () {
    test('toString contains url', () {
      const exception = TaroUriParseException(url: 'invalid://url');
      expect(exception.toString(), contains('TaroUriParseException'));
      expect(exception.toString(), contains('invalid://url'));
    });

    test('url property', () {
      const exception = TaroUriParseException(url: 'not-a-url');
      expect(exception.url, equals('not-a-url'));
    });
  });

  group('TaroNetworkException', () {
    test('toString contains url and error', () {
      final exception = TaroNetworkException(
        url: 'https://example.com',
        error: Exception('Connection failed'),
      );
      expect(exception.toString(), contains('TaroNetworkException'));
      expect(exception.toString(), contains('https://example.com'));
      expect(exception.toString(), contains('Connection failed'));
    });

    test('properties', () {
      final error = Exception('Timeout');
      final exception = TaroNetworkException(
        url: 'https://test.com',
        error: error,
      );
      expect(exception.url, equals('https://test.com'));
      expect(exception.error, equals(error));
    });
  });

  group('TaroHttpResponseException', () {
    test('toString contains all properties', () {
      const exception = TaroHttpResponseException(
        statusCode: 404,
        reasonPhrase: 'Not Found',
        contentLength: 0,
        headers: {'content-type': 'text/plain'},
        isRedirect: false,
      );
      final str = exception.toString();
      expect(str, contains('statusCode=404'));
      expect(str, contains('reasonPhrase=Not Found'));
      expect(str, contains('contentLength=0'));
      expect(str, contains('isRedirect=false'));
    });

    test('properties', () {
      const exception = TaroHttpResponseException(
        statusCode: 500,
        reasonPhrase: 'Internal Server Error',
        contentLength: 100,
        headers: {'x-custom': 'value'},
        isRedirect: true,
      );
      expect(exception.statusCode, equals(500));
      expect(exception.reasonPhrase, equals('Internal Server Error'));
      expect(exception.contentLength, equals(100));
      expect(exception.headers, equals({'x-custom': 'value'}));
      expect(exception.isRedirect, isTrue);
    });

    test('nullable properties', () {
      const exception = TaroHttpResponseException(
        statusCode: 503,
        reasonPhrase: null,
        contentLength: null,
        headers: {},
        isRedirect: false,
      );
      expect(exception.reasonPhrase, isNull);
      expect(exception.contentLength, isNull);
    });
  });

  group('TaroEmptyResponseException', () {
    test('toString contains url', () {
      const exception = TaroEmptyResponseException(url: 'https://empty.com');
      expect(exception.toString(), contains('TaroEmptyResponseException'));
      expect(exception.toString(), contains('https://empty.com'));
    });

    test('url property', () {
      const exception = TaroEmptyResponseException(url: 'https://no-body.com');
      expect(exception.url, equals('https://no-body.com'));
    });
  });

  group('TaroException sealed class', () {
    test('all exceptions are TaroException', () {
      const loadException = TaroLoadException(message: 'test');
      final storageException = TaroStorageException(
        exception: Exception('test'),
      );
      const uriException = TaroUriParseException(url: 'test');
      final networkException = TaroNetworkException(
        url: 'test',
        error: Exception('test'),
      );
      const httpException = TaroHttpResponseException(
        statusCode: 400,
        reasonPhrase: null,
        contentLength: null,
        headers: {},
        isRedirect: false,
      );
      const emptyException = TaroEmptyResponseException(url: 'test');

      expect(loadException, isA<TaroException>());
      expect(storageException, isA<TaroException>());
      expect(uriException, isA<TaroException>());
      expect(networkException, isA<TaroException>());
      expect(httpException, isA<TaroException>());
      expect(emptyException, isA<TaroException>());
    });
  });
}
