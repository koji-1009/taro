import 'dart:typed_data';

import 'package:quiver/core.dart';
import 'package:taro/src/loader/storage_file.dart';
import 'package:taro/src/storage/shared.dart' as storage;
import 'package:taro/src/taro_exception.dart';

/// `StorageLoader` is a class that manages the loading and saving of data from and to storage.
class StorageLoader {
  /// Creates a new instance of `StorageLoader`.
  const StorageLoader();

  /// Loads the data from the provided URL from storage.
  /// Returns a Future that completes with a `StorageFile` object.
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

  /// Saves the provided data to storage with the given URL, content type, and an optional expiration date.
  /// Returns a Future that completes when the data is saved.
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
