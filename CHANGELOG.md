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
