import 'dart:js_interop';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:taro/src/storage/cache_file_info.dart';
import 'package:taro/src/storage/web_cache.dart';

const _cacheName = 'taro';

/// Load [Uint8List] from storage.
Future<Uint8List?> load({
  required String filename,
}) async {
  final cacheStorage = window.caches;
  if (cacheStorage == null) {
    throw UnsupportedError('[taro][storage] Cache API is not supported');
  }

  final cache = await cacheStorage.open(_cacheName.toJS).toDart;
  final cacheFileInfoFile = 'info_$filename'.toJS;
  final cacheFileInfoJs = await cache.match(cacheFileInfoFile).toDart;
  if (cacheFileInfoJs == null) {
    // cache info file is not found
    return null;
  }

  final cacheFileName = filename.toJS;
  final cacheFileJs = await cache.match(cacheFileName).toDart;
  if (cacheFileJs == null) {
    await cache.delete(cacheFileInfoFile).toDart;
    return null;
  }

  final cacheFileInfo = await cacheFileInfoJs.text().toDart;
  final cacheInfo = CacheFileInfo.fromJson(cacheFileInfo.toDart);

  final now = clock.now();
  if (cacheInfo.expireAt != null && cacheInfo.expireAt!.isBefore(now)) {
    // cache is expired
    await cache.delete(cacheFileName).toDart;
    await cache.delete(cacheFileInfoFile).toDart;
    return null;
  }

  final arrayBufferJs = await cacheFileJs.arrayBuffer().toDart;
  final bytes = arrayBufferJs.toDart.asUint8List();
  return bytes;
}

/// Save [Uint8List] to storage.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  required DateTime? expireAt,
}) async {
  final cacheStorage = window.caches;
  if (cacheStorage == null) {
    throw UnsupportedError('[taro][storage] Cache API is not supported');
  }

  final cacheFileInfo = CacheFileInfo(
    contentType: contentType,
    expireAt: expireAt,
  );

  final cacheFileName = filename.toJS;
  final cacheFileInfoFile = 'info_$filename'.toJS;

  final cache = await cacheStorage.open(_cacheName.toJS).toDart;
  await cache
      .put(
        cacheFileName,
        JSResponse(
          bytes.toJS,
          JSResponseOptions(
            headers: {
              'content-type': contentType,
              'content-length': '${bytes.length}',
            }.jsify(),
          ),
        ),
      )
      .toDart;

  final cacheFileInfoJson = cacheFileInfo.toJson();
  await cache
      .put(
        cacheFileInfoFile,
        JSResponse(
          cacheFileInfoJson.toJS,
          JSResponseOptions(
            headers: {
              'content-type': 'text/plain',
              'content-length': '${cacheFileInfoJson.length}'
            }.jsify(),
          ),
        ),
      )
      .toDart;
}
