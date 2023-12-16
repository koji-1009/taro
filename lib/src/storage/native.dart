import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taro/src/loader/storage_file.dart';

Future<StorageFile?> load({
  required String filename,
}) async {
  final Directory appCacheDir = await getApplicationCacheDirectory();
  final cacheDir = Directory('${appCacheDir.path}/taro');
  final cacheFile = File('${cacheDir.path}/$filename');
  final cacheInfoFile = File('${cacheDir.path}/$filename.json');

  if (!await cacheInfoFile.exists()) {
    // cache info file is not found
    return null;
  }
  if (!await cacheFile.exists()) {
    // cache file is not found
    await cacheInfoFile.delete();
    return null;
  }

  final cacheInfoFileData = await cacheInfoFile.readAsString();
  final cacheFileInfo = CacheInfo.fromJson(cacheInfoFileData);

  final now = DateTime.now();
  if (cacheFileInfo.expireAt != null && cacheFileInfo.expireAt!.isBefore(now)) {
    // cache is found but expired
    await cacheFile.delete();
    await cacheInfoFile.delete();
    return null;
  }

  final bytes = await cacheFile.readAsBytes();
  return (
    bytes: bytes,
    info: cacheFileInfo,
  );
}

Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  DateTime? expireAt,
}) async {
  final cacheFileInfo = CacheInfo(
    expireAt: expireAt,
  );

  final appCacheDir = await getApplicationCacheDirectory();
  final cacheDir = Directory('${appCacheDir.path}/taro');
  if (!await cacheDir.exists()) {
    await cacheDir.create();
  }

  final cacheFile = File('${cacheDir.path}/$filename');
  final cacheInfoFile = File('${cacheDir.path}/$filename.json');

  await cacheFile.writeAsBytes(bytes);
  await cacheInfoFile.writeAsString(cacheFileInfo.toJson());
}
