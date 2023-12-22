/// `TaroException` is a base class for all exceptions in the Taro.
sealed class TaroException implements Exception {
  const TaroException();
}

/// `TaroLoadException` is thrown when there is an issue with loading data in the Taro library.
final class TaroLoadException extends TaroException {
  const TaroLoadException({
    required this.message,
  });

  final String message;

  @override
  String toString() {
    return 'TaroLoadException: message=$message';
  }
}

/// `TaroMemoryException` is thrown when there is an issue with memory operations in the Taro library.
/// It includes the maximum size of the memory and the original exception that caused the error.
final class TaroMemoryException extends TaroException {
  const TaroMemoryException({
    required this.maximumSize,
    required this.exception,
  });

  final int? maximumSize;
  final Exception exception;

  @override
  String toString() {
    return 'TaroMemoryException: maximumSize=$maximumSize, exception=$exception';
  }
}

/// `TaroStorageException` is thrown when there is an issue with storage operations in the Taro library.
/// It includes the original exception that caused the error.
final class TaroStorageException extends TaroException {
  const TaroStorageException({
    required this.exception,
  });

  final Exception exception;

  @override
  String toString() {
    return 'TaroStorageException: exception=$exception';
  }
}

/// `TaroUriParseException` is thrown when there is an issue with parsing a URI in the Taro library.
/// It includes the URL that was being parsed and the original FormatException that caused the error.
final class TaroUriParseException extends TaroException {
  const TaroUriParseException({
    required this.url,
    required this.error,
  });

  final String url;
  final FormatException error;

  @override
  String toString() {
    return 'TaroUriParseException: url=$url, error=$error';
  }
}

/// `TaroNetworkException` is thrown when there is an issue with network operations in the Taro library.
/// It includes the URL that was being accessed and the original error that caused the issue.
final class TaroNetworkException extends TaroException {
  const TaroNetworkException({
    required this.url,
    required this.error,
  });

  final String url;
  final Exception error;

  @override
  String toString() {
    return 'TaroNetworkException: url=$url, error=$error';
  }
}

/// `TaroHttpResponseException` is thrown when there is an issue with the HTTP response in the Taro library.
/// It includes the status code, reason phrase, content length, headers, and whether the response is a redirect.
/// This exception is thrown when the status code is not in the range 200-399.
final class TaroHttpResponseException extends TaroException {
  const TaroHttpResponseException({
    required this.statusCode,
    required this.reasonPhrase,
    required this.contentLength,
    required this.headers,
    required this.isRedirect,
  });

  final int statusCode;
  final String? reasonPhrase;
  final int? contentLength;
  final Map<String, String> headers;
  final bool isRedirect;

  @override
  String toString() {
    return 'TaroHttpException: statusCode=$statusCode, reasonPhrase=$reasonPhrase, contentLength=$contentLength, headers=$headers, isRedirect=$isRedirect';
  }
}

/// `TaroEmptyResponseException` is thrown when there is an issue with the HTTP response in the Taro library.
/// It includes the URL that was being accessed.
/// This exception is thrown when the response body is empty.
final class TaroEmptyResponseException extends TaroException {
  const TaroEmptyResponseException({
    required this.url,
  });

  final String url;

  @override
  String toString() {
    return 'TaroEmptyResponseException: url=$url';
  }
}

/// `TaroResizeException` is thrown when there is an issue with resizing an image in the Taro library.
/// It includes the original exception that caused the error.
/// This exception is thrown when the status code is not in the range 200-399.
/// Compare this snippet from lib/src/taro_exception.dart:
final class TaroResizeException extends TaroException {
  const TaroResizeException({
    required this.exception,
  });

  final Exception exception;

  @override
  String toString() {
    return 'TaroResizeException: exception=$exception';
  }
}
