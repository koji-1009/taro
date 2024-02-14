import 'dart:js_interop';

@JS()
@staticInterop
external Window get window;

/// see [https://developer.mozilla.org/en-US/docs/Web/API/Window]
@JS('Window')
@staticInterop
class Window {}

extension WindowExtension on Window {
  external CacheStorage? get caches;
}

/// see [https://developer.mozilla.org/en-US/docs/Web/API/Cache]
@JS('Cache')
@staticInterop
class Cache {}

extension CacheExtension on Cache {
  external JSPromise match(JSString request);

  external JSPromise put(JSString request, Response response);

  external JSPromise delete(JSString request);
}

/// see [https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage]
@JS('CacheStorage')
@staticInterop
class CacheStorage {}

extension CacheStorageExtension on CacheStorage {
  external JSPromise open(JSString cacheName);
}

/// see [https://developer.mozilla.org/en-US/docs/Web/API/Response]
@JS('Response')
@staticInterop
class Response {
  external factory Response([
    JSAny? body,
    ResponseInit init,
  ]);
}

extension ResponseExtension on Response {
  external JSPromise text();

  external JSPromise arrayBuffer();
}

@JS()
@staticInterop
@anonymous
class ResponseInit {
  external factory ResponseInit({
    JSAny? headers,
  });
}
