import 'dart:js_interop';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch]
@JS()
external JSPromise<Response> fetch(
  String url,
  Headers headers,
);

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
extension type Response._(JSObject _) implements JSObject {
  external int get status;

  external String get statusText;

  external bool get redirected;

  external Headers get headers;

  external JSPromise<JSArrayBuffer> arrayBuffer();
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
