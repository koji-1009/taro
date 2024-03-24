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

  final cache = await cacheStorage.open(_cacheName).toDart;

  final cacheInfoFilename = 'info_$filename';
  final cacheFileInfoJs = await cache.match(cacheInfoFilename).toDart;
  if (cacheFileInfoJs == null) {
    // cache info file is not found
    return null;
  }

  final cacheFileJs = await cache.match(filename).toDart;
  if (cacheFileJs == null) {
    await cache.delete(cacheInfoFilename).toDart;
    return null;
  }

  final cacheFileInfo = await cacheFileInfoJs.text().toDart;
  final cacheInfo = CacheFileInfo.fromJson(cacheFileInfo.toDart);
  if (cacheInfo.expireAt != null && cacheInfo.expireAt!.isBefore(clock.now())) {
    // cache is expired
    await cache.delete(filename).toDart;
    await cache.delete(cacheInfoFilename).toDart;
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

  final cache = await cacheStorage.open(_cacheName).toDart;
  await cache
      .put(
        filename,
        JSResponse.bytes(
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

  final cacheInfoFilename = 'info_$filename';
  final cacheInfoFileJson = CacheFileInfo(
    contentType: contentType,
    expireAt: expireAt,
  ).toJson();
  await cache
      .put(
        cacheInfoFilename,
        JSResponse.text(
          cacheInfoFileJson,
          JSResponseOptions(
            headers: {
              'content-type': 'text/plain',
              'content-length': '${cacheInfoFileJson.length}'
            }.jsify(),
          ),
        ),
      )
      .toDart;
}
