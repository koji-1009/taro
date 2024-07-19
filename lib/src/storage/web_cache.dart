import 'dart:js_interop';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window]
@JS()
external Window get window;

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window]
extension type Window(JSObject _) implements JSObject {
  external CacheStorage? get caches;
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Cache]
extension type Cache(JSObject _) implements JSObject {
  external JSPromise<Response?> match(
    String request,
  );

  external JSPromise put(
    String request,
    Response response,
  );

  external JSPromise delete(
    String request,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage]
extension type CacheStorage(JSObject _) implements JSObject {
  external JSPromise<Cache> open(
    String cacheName,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
extension type Response._(JSObject _) implements JSObject {
  external factory Response.bytes([
    JSUint8Array body,
    ResponseOptions options,
  ]);

  external factory Response.text([
    String body,
    ResponseOptions options,
  ]);

  external JSPromise<JSString> text();

  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response/Response#options]
extension type ResponseOptions._(JSObject _) implements JSObject {
  external factory ResponseOptions({
    JSAny? headers,
  });
}
