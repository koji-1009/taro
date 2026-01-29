/// [TaroException] is a base class for all exceptions in the Taro.
sealed class TaroException implements Exception {
  /// Creates a [TaroException].
  const TaroException();
}

/// [TaroLoadException] is thrown when there is an issue with loading data in the Taro library.
final class TaroLoadException extends TaroException {
  /// Creates a [TaroLoadException].
  const TaroLoadException({
    required this.message,
  });

  /// The message describing the error.
  final String message;

  @override
  String toString() => 'TaroLoadException: message=$message';
}

/// [TaroStorageException] is thrown when there is an issue with storage operations in the Taro library.
/// It includes the original exception that caused the error.
final class TaroStorageException extends TaroException {
  /// Creates a [TaroStorageException].
  const TaroStorageException({
    required this.exception,
  });

  /// The original exception that caused the error.
  final Exception exception;

  @override
  String toString() => 'TaroStorageException: exception=$exception';
}

/// [TaroUriParseException] is thrown when there is an issue with parsing a URI in the Taro library.
/// It includes the URL that was being parsed.
final class TaroUriParseException extends TaroException {
  /// Creates a [TaroUriParseException].
  const TaroUriParseException({
    required this.url,
  });

  /// The URL that was being parsed.
  final String url;

  @override
  String toString() => 'TaroUriParseException: url=$url';
}

/// [TaroNetworkException] is thrown when there is an issue with network operations in the Taro library.
/// It includes the URL that was being accessed and the original error that caused the issue.
final class TaroNetworkException extends TaroException {
  /// Creates a [TaroNetworkException].
  const TaroNetworkException({
    required this.url,
    required this.error,
  });

  /// The URL that was being accessed.
  final String url;

  /// The original error that caused the issue.
  final Exception error;

  @override
  String toString() => 'TaroNetworkException: url=$url, error=$error';
}

/// [TaroHttpResponseException] is thrown when there is an issue with the HTTP response in the Taro library.
/// It includes the status code, reason phrase, content length, headers, and whether the response is a redirect.
/// This exception is thrown when the status code is not in the range 200-399.
final class TaroHttpResponseException extends TaroException {
  /// Creates a [TaroHttpResponseException].
  const TaroHttpResponseException({
    required this.statusCode,
    required this.reasonPhrase,
    required this.contentLength,
    required this.headers,
    required this.isRedirect,
  });

  /// The status code of the response.
  final int statusCode;

  /// The reason phrase of the response.
  final String? reasonPhrase;

  /// The content length of the response.
  final int? contentLength;

  /// The headers of the response.
  final Map<String, String> headers;

  /// Whether the response is a redirect.
  final bool isRedirect;

  @override
  String toString() =>
      'TaroHttpException: statusCode=$statusCode, reasonPhrase=$reasonPhrase, contentLength=$contentLength, headers=$headers, isRedirect=$isRedirect';
}

/// [TaroEmptyResponseException] is thrown when there is an issue with the HTTP response in the Taro library.
/// It includes the URL that was being accessed.
/// This exception is thrown when the response body is empty.
final class TaroEmptyResponseException extends TaroException {
  /// Creates a [TaroEmptyResponseException].
  const TaroEmptyResponseException({
    required this.url,
  });

  /// The URL that was being accessed.
  final String url;

  @override
  String toString() => 'TaroEmptyResponseException: url=$url';
}
