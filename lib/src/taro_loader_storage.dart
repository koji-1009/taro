import 'dart:typed_data';

import 'package:quiver/core.dart';
import 'package:taro/src/storage/shared.dart' as storage;
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_type.dart';

/// The [TaroLoaderStorage] class is used to load and save data from storage.
class TaroLoaderStorage {
  /// Creates a [TaroLoaderStorage].
  const TaroLoaderStorage();

  /// Loads the data from the provided URL from storage.
  /// Returns a Future that completes with the data.
  Future<Uint8List?> load({
    required String url,
    required TaroResizeOption resizeOption,
  }) async {
    try {
      return await storage.load(
        filename: '${hashObjects([url, resizeOption])}',
      );
    } on Exception catch (exception) {
      throw TaroStorageException(
        exception: exception,
      );
    }
  }

  /// Saves the data to the provided URL to storage.
  Future<void> save({
    required String url,
    required Uint8List bytes,
    required String contentType,
    required DateTime? expireAt,
    required TaroResizeOption resizeOption,
  }) async {
    try {
      return await storage.save(
        filename: '${hashObjects([url, resizeOption])}',
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
