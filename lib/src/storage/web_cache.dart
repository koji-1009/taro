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
  external JSPromise match(
    JSString request,
  );

  external JSPromise put(
    JSString request,
    Response response,
  );

  external JSPromise delete(
    JSString request,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage]
extension type CacheStorage(JSObject _) implements JSObject {
  external JSPromise open(
    JSString cacheName,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
extension type Response._(JSObject _) implements JSObject {
  external factory Response([
    JSAny? body,
    ResponseOptions options,
  ]);

  external JSPromise text();

  external JSPromise arrayBuffer();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response/Response#options]
extension type ResponseOptions._(JSObject _) implements JSObject {
  external factory ResponseOptions({
    JSAny? headers,
  });
}
