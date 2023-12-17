import 'dart:typed_data';

import 'package:quiver/core.dart';
import 'package:taro/src/loader/storage_file.dart';
import 'package:taro/src/storage/shared.dart' as storage;
import 'package:taro/src/taro_exception.dart';

class StorageLoader {
  const StorageLoader();

  Future<StorageFile?> load({
    required String url,
  }) async {
    try {
      return storage.load(
        filename: '${hashObjects([url])}',
      );
    } on Exception catch (exception) {
      throw TaroStorageException(
        exception: exception,
      );
    }
  }

  Future<void> save({
    required String url,
    required Uint8List bytes,
    required String contentType,
    DateTime? expireAt,
  }) async {
    try {
      return storage.save(
        filename: '${hashObjects([url])}',
        bytes: bytes,
        contentType: contentType,
        expireAt: expireAt,
      );
    } on Exception catch (exception) {
      throw TaroStorageException(
        exception: exception,
      );
    }
  }
}
