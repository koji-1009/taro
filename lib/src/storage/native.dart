import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taro/src/storage/cache_file_info.dart';

/// Load [Uint8List] from storage.
Future<Uint8List?> load({
  required String filename,
}) async {
  final appCacheDir = await getApplicationCacheDirectory();
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
  final cacheFileInfo = CacheFileInfo.fromJson(cacheInfoFileData);

  final now = clock.now();
  if (cacheFileInfo.expireAt != null && cacheFileInfo.expireAt!.isBefore(now)) {
    // cache is found but expired
    await cacheFile.delete();
    await cacheInfoFile.delete();
    return null;
  }

  final bytes = await cacheFile.readAsBytes();
  return bytes;
}

/// Save [Uint8List] to storage.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  required DateTime? expireAt,
}) async {
  final cacheFileInfo = CacheFileInfo(
    contentType: contentType,
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
