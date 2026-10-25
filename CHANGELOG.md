## 2.1.0

* **FIX**: Include request headers in the storage cache key, so requests to the same URL with different headers (e.g. `Authorization`) no longer share a cache entry. `TaroLoaderStorage.load` and `save` take an optional `headers` argument; requests without headers keep the previous cache file name.
* **FIX**: Time out a stalled response body in the default `HttpClient`. The timeout now also applies to each wait for the next part of the body, not only to the response headers; a slow download that keeps receiving data does not time out.
* **FIX**: Set the timeout as `connectionTimeout` on native, so connecting to a host that does not answer fails with a `TaroNetworkException` after the timeout.
* **FIX**: Abort the `fetch` on web when the request times out, instead of leaving it running in the background.
* **FIX**: Wrap failed `fetch` calls on web in an `Exception`, so they are thrown as `TaroNetworkException` like native network errors.
* **FIX**: Report the size of the body as `contentLength` on native, as on web. It was the `Content-Length` header: the size before decompression for a gzip body, and -1 without the header.
* **FIX**: Parse the `max-age` directive case-insensitively and accept a quoted value.
* **FIX**: Compare `TaroImage` headers by content when `useHeadersHashCode` is true, so maps with the same entries identify the same image.
* **FIX**: Correct the names printed by `TaroImage.toString` and `TaroHttpResponseException.toString`.
* **DOCS**: Fix incorrect descriptions in doc comments and README.
* **CHORE**: Bump `codecov/codecov-action` to 7.1.1 and `koji-1009/setup-flutter` to 1.4.1.

## 2.0.5

* **FIX**: Send request headers on web. `fetch` was called with a `Headers` instance where its init dictionary was expected, so every header passed to `Taro` was silently dropped in web builds.
* **FIX**: Throw a `FormatException` instead of a `TypeError` when a cache file info is corrupted, so the failure is wrapped in `TaroStorageException` rather than escaping as an `Error`.
* **FIX**: Await the decoded image inside the `try` block of `TaroImage` so decoding failures are handled by the surrounding error handling.
* **TEST**: Raise line coverage from 82.4% to 99.7%, and add browser tests for the web network and storage implementations.
* **CHORE**: Upload coverage to Codecov and run the browser tests in CI.
* **CHORE**: Replace the `strict-raw-types` analyzer mode with the `no_raw_types` and `no_dynamic_casts` lints, and enable `strict-inference`.

## 2.0.4

* **FIX**: Resolve equality asymmetry in `TaroImage` when `useHeadersHashCode` differs between instances.
* **FIX**: `Taro.configure()` no longer resets `onStorageError` callback when not explicitly provided.
* **FIX**: Use recursive directory creation in native storage to prevent race conditions.
* **TEST**: Add dedicated `TaroLoader` tests for storage/network orchestration and error callback behavior.
* **TEST**: Expand test coverage for `age` header, 3xx status codes, `ResizeImage` wrapping, and `configure()` parameter preservation.

## 2.0.3

* **FEAT**: Add `TaroStorageFailureException` and `TaroStorageOperationType` for storage error handling.
* **FEAT**: Add `onStorageError` callback to `Taro` class for monitoring storage failures.
* **FEAT**: Add `topics` to pubspec.yaml for better discoverability on pub.dev.
* **REFACTOR**: Add `@immutable` annotation to `CacheFileInfo`.
* **REFACTOR**: Remove duplicate `key` assignment in `TaroWidget`.
* **TEST**: Add comprehensive tests for exception classes and `CacheFileInfo`.
* **TEST**: Add `tearDown` to existing tests for better isolation.

## 2.0.2

* **FIX**: Fix lint rule.

## 2.0.1

* **FIX**: Handle deleted cache directory in `native.dart`.
* **REFACTOR**: Rearrange test directory structure.
* **DOCS**: Update README badges and examples.

## 2.0.0

* **BREAKING CHANGE**: Refactor `TaroHttpResponse` from `Record` to `class`.
* **BREAKING CHANGE**: `TaroHttpResponse` constructor is no longer `const` due to header normalization.
* **FEAT**: Add `toString`, `==`, `hashCode` implementation to `TaroHttpResponse`.
* **FEAT**: Normalize `TaroHttpResponse` headers keys to lowercase.

## 1.5.0

* **BREAKING CHANGE**: Remove `TaroResizeOption`, `TaroResizeOptionSkip`, and `TaroResizeOptionMemory`.
* **BREAKING CHANGE**: `Taro.loadImageProvider` and `TaroWidget` now use `maxWidth` and `maxHeight` arguments instead of `resizeOption`.

## 1.4.0

* **BREAKING CHANGE**: Remove `image` dependency.
* **BREAKING CHANGE**: Remove `TaroResizer`, `TaroResizeOptionDisk`, and `TaroResizeFormat`.
* **BREAKING CHANGE**: Remove `resizeOption` argument from `loadBytes`.
* **BREAKING CHANGE**: Remove `networkLoaderResizer` setter from `Taro`.

## 1.3.0

* Add `customCacheDuration` option to `TaroHeaderOption`
* **BREAKING CHANGE**: Convert `TaroHeaderOption` from record to class for better extensibility
* Add `toString()`, `==`, and `hashCode` to all `TaroResizeOption` subclasses
* Fix `cache-control` header parsing to support multiple directives
* Improve error handling in `TaroResizer`

## 1.2.0

* Refactor `TaroResizeOption`

## 1.1.0

* Remove `http` dependency
* Use `dart.library.io` and `dart.library.js_interop`

## 1.0.1

* Add sample code with `Dio` http client
* Update README
* Code cleanup

## 1.0.0

* Initial stable release

## 0.3.1

* Code cleanup

## 0.3.0

* http 1.2.1

## 0.2.2

* Change js class names to match Dart class names

## 0.2.1

* Specify generic type

## 0.2.0

* Require Dart 3.3.0 and Flutter 3.19.0
* Update to extension type

## 0.1.0

* Migrate to js_interop
* Create filename by sha256 hash of URL and options

## 0.0.3

* Cleanup API
* Add comments

## 0.0.2

* More documentation

## 0.0.1

* Initial alpha release
