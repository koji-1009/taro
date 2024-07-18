import 'dart:js_interop';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch]
@JS()
external JSPromise<JSResponse> fetch(
  String url,
  JSHeaders headers,
);

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
extension type JSResponse._(JSObject _) implements JSObject {
  external int get status;

  external String get statusText;

  external bool get redirected;

  external JSHeaders get headers;

  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Headers]
@JS('Headers')
extension type JSHeaders._(JSObject _) implements JSObject {
  external factory JSHeaders([JSObject init]);

  external void append(
    String name,
    String value,
  );

  external void forEach(JSFunction callback);
}
