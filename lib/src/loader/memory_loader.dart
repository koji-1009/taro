import 'dart:typed_data';

import 'package:quiver/cache.dart';
import 'package:quiver/core.dart';
import 'package:taro/src/taro_exception.dart';
import 'package:taro/src/taro_resizer.dart';

typedef _MemoryCache = ({
  Uint8List bytes,
  DateTime? expireAt,
});

/// `MemoryLoader` is a class that manages the loading of data into memory.
/// It uses a cache to store data, with an optional maximum size.
class MemoryLoader {
  /// Creates a new instance of `MemoryLoader`.
  /// The [maximumSize] parameter sets the maximum size of the cache.
  MemoryLoader({
    this.maximumSize,
  });

  /// The maximum size of the cache.
  final int? maximumSize;

  /// The cache used to store data.
  late final _cache = MapCache<int, _MemoryCache>.lru(
    maximumSize: maximumSize,
  );

  /// Loads the data from the provided URL into memory.
  /// If the data is already in the cache and has not expired, it is returned from the cache.
  /// If the data is not in the cache or has expired, `null` is returned.
  Future<Uint8List?> load({
    required String url,
    required TaroResizeOption resizeOption,
  }) async {
    try {
      final key = hashObjects([url, resizeOption]);
      final cache = await _cache.get(key);
      if (cache == null) {
        // cache is not found
        return null;
      }

      final now = DateTime.now();
      if (cache.expireAt != null && cache.expireAt!.isBefore(now)) {
        // cache is found but expired
        await _cache.invalidate(key);
        return null;
      }

      return cache.bytes;
    } on Exception catch (exception) {
      throw TaroMemoryException(
        maximumSize: maximumSize,
        exception: exception,
      );
    }
  }

  /// Saves the provided data to memory with the given URL and an optional expiration date.
  /// Returns a Future that completes when the data is saved.
  /// If the data is already in the cache, it is overwritten. Otherwise, it is added to the cache.
  Future<void> save({
    required String url,
    required Uint8List bytes,
    required DateTime? expireAt,
    required TaroResizeOption resizeOption,
  }) async {
    try {
      final key = hashObjects([url, resizeOption]);
      await _cache.set(
        key,
        (
          bytes: bytes,
          expireAt: expireAt,
        ),
      );
    } on Exception catch (exception) {
      throw TaroMemoryException(
        maximumSize: maximumSize,
        exception: exception,
      );
    }
  }
}
