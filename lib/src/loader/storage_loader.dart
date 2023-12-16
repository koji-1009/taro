import 'dart:typed_data';

import 'package:quiver/core.dart';
import 'package:taro/src/loader/storage_file.dart';
import 'package:taro/src/storage/shared.dart' as storage;

class StorageLoader {
  const StorageLoader();

  Future<StorageFile?> load({
    required String url,
  }) async =>
      storage.load(
        filename: '${hashObjects([url])}',
      );

  Future<void> save({
    required String url,
    required Uint8List bytes,
    required String contentType,
    DateTime? expireAt,
  }) async =>
      storage.save(
        filename: '${hashObjects([url])}',
        bytes: bytes,
        contentType: contentType,
        expireAt: expireAt,
      );
}
