import 'dart:js_interop';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch]
@JS()
external JSPromise<Response> fetch(
  String url,
  RequestInit init,
);

/// [https://developer.mozilla.org/en-US/docs/Web/API/RequestInit]
extension type RequestInit._(JSObject _) implements JSObject {
  external factory RequestInit({
    Headers headers,
    AbortSignal signal,
  });
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/AbortController]
extension type AbortController._(JSObject _) implements JSObject {
  external factory AbortController();

  external AbortSignal get signal;

  external void abort();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal]
extension type AbortSignal._(JSObject _) implements JSObject {}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
extension type Response._(JSObject _) implements JSObject {
  external int get status;

  external String get statusText;

  external bool get redirected;

  external Headers get headers;

  external ReadableStream? get body;
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/ReadableStream]
extension type ReadableStream._(JSObject _) implements JSObject {
  external ReadableStreamDefaultReader getReader();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/ReadableStreamDefaultReader]
extension type ReadableStreamDefaultReader._(JSObject _) implements JSObject {
  external JSPromise<ReadableStreamReadResult> read();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/ReadableStreamDefaultReader/read#return_value]
extension type ReadableStreamReadResult._(JSObject _) implements JSObject {
  external bool get done;

  external JSUint8Array? get value;
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Headers]
extension type Headers._(JSObject _) implements JSObject {
  external factory Headers([JSObject init]);

  external void append(
    String name,
    String value,
  );

  external void forEach(JSFunction callback);
}
