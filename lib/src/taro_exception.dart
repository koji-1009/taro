sealed class TaroException implements Exception {
  const TaroException();
}

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
