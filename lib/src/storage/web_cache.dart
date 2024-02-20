import 'dart:js_interop';

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window]
@JS()
external JSWindow get window;

/// [https://developer.mozilla.org/en-US/docs/Web/API/Window]
@JS('Window')
extension type JSWindow(JSObject _) implements JSObject {
  external JSCacheStorage? get caches;
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Cache]
@JS('Cache')
extension type JSCache(JSObject _) implements JSObject {
  external JSPromise<JSResponse?> match(
    JSString request,
  );

  external JSPromise put(
    JSString request,
    JSResponse response,
  );

  external JSPromise delete(
    JSString request,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage]
@JS('CacheStorage')
extension type JSCacheStorage(JSObject _) implements JSObject {
  external JSPromise<JSCache> open(
    JSString cacheName,
  );
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response]
@JS('Response')
extension type JSResponse._(JSObject _) implements JSObject {
  external factory JSResponse([
    JSAny? body,
    JSResponseOptions options,
  ]);

  external JSPromise<JSString> text();

  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// [https://developer.mozilla.org/en-US/docs/Web/API/Response/Response#options]
extension type JSResponseOptions._(JSObject _) implements JSObject {
  external factory JSResponseOptions({
    JSAny? headers,
  });
}
