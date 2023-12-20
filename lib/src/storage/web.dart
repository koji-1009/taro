import 'dart:js_interop';
import 'dart:typed_data';

import 'package:js/js_util.dart' as js_util;
import 'package:taro/src/loader/storage_file.dart';
import 'package:taro/src/storage/web_cache.dart';

/// Loads a `StorageFile` with the provided filename.
Future<StorageFile?> load({
  required String filename,
}) async {
  final cacheFileName = filename.toJS;
  final cacheFileInfoFile = 'info_$filename'.toJS;

  final cacheStorage = window.caches;
  if (cacheStorage == null) {
    throw UnsupportedError('[taro][storage] Cache API is not supported');
  }

  final cache = await js_util.promiseToFuture<Cache>(
    cacheStorage.open('taro'),
  );

  final cacheFileInfoJs = await js_util.promiseToFuture<Response?>(
    cache.match(cacheFileInfoFile),
  );
  final cacheFileJs = await js_util.promiseToFuture<Response?>(
    cache.match(cacheFileName),
  );

  if (cacheFileInfoJs == null) {
    // cache info file is not found
    return null;
  }
  if (cacheFileJs == null) {
    await js_util.promiseToFuture(
      cache.delete(cacheFileInfoFile),
    );
    return null;
  }

  final cacheFileInfo = await js_util.promiseToFuture(
    cacheFileInfoJs.text(),
  );
  final cacheInfo = CacheInfo.fromJson(cacheFileInfo);

  final now = DateTime.now();
  if (cacheInfo.expireAt != null && cacheInfo.expireAt!.isBefore(now)) {
    // cache is expired
    await js_util.promiseToFuture(
      cache.delete(cacheFileName),
    );
    await js_util.promiseToFuture(
      cache.delete(cacheFileInfoFile),
    );
    return null;
  }

  final bufferJs = await js_util.promiseToFuture<JSArrayBuffer>(
    cacheFileJs.arrayBuffer(),
  );
  final bytes = Uint8List.view(bufferJs.toDart);
  return (
    bytes: bytes,
    info: cacheInfo,
  );
}

/// Saves the provided bytes as a `StorageFile` with the provided filename and content type.
///
/// The [expireAt] parameter determines when the file should expire.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  DateTime? expireAt,
}) async {
  final cacheFileInfo = CacheInfo(
    expireAt: expireAt,
  );

  final cacheFileName = filename.toJS;
  final cacheFileInfoFile = 'info_$filename'.toJS;

  final cacheStorage = window.caches;
  if (cacheStorage == null) {
    throw UnsupportedError('[taro][storage] Cache API is not supported');
  }

  final cache = await js_util.promiseToFuture<Cache>(
    cacheStorage.open('taro'),
  );
  await js_util.promiseToFuture<void>(
    cache.put(
      cacheFileName,
      Response(
        bytes.toJS,
        ResponseInit(
          headers: js_util.jsify(
            {
              'content-type': contentType,
              'content-length': '${bytes.length}',
            },
          ),
        ),
      ),
    ),
  );

  final cacheFileInfoJson = cacheFileInfo.toJson();
  await js_util.promiseToFuture<void>(
    cache.put(
      cacheFileInfoFile,
      Response(
        cacheFileInfoJson.toJS,
        ResponseInit(
          headers: js_util.jsify(
            {
              'content-type': 'text/plain',
              'content-length': '${cacheFileInfoJson.length}'
            },
          ),
        ),
      ),
    ),
  );
}
