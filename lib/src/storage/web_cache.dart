import 'dart:js_interop';

import 'package:js/js.dart';

@JS()
class Promise<T> {
  external Promise(
    void Function(
      void Function(T result) resolve,
      Function reject,
    ) executor,
  );

  external Promise then(
    void Function(T result) onFulfilled, [
    Function onRejected,
  ]);
}

@JS()
external Window get window;

@JS('Window')
@staticInterop
class Window {}

extension WindowExtension on Window {
  external CacheStorage? get caches;
}

@JS('Cache')
@staticInterop
class Cache {}

extension CacheExtension on Cache {
  external Promise<Response?> match(JSAny request);

  external Promise<void> put(JSAny request, Response response);

  external Promise<void> delete(JSAny request);
}

@JS('CacheStorage')
@staticInterop
class CacheStorage {}

extension CacheStorageExtension on CacheStorage {
  external Promise<Cache> open(String cacheName);
}

@JS('Response')
@staticInterop
class Response {
  external factory Response([
    JSAny? body,
    ResponseInit init,
  ]);
}

extension ResponseExtension on Response {
  external Promise<String> text();

  external Promise<JSArrayBuffer> arrayBuffer();
}

@JS()
@staticInterop
@anonymous
class ResponseInit {
  external factory ResponseInit({
    JSAny headers,
  });
}
