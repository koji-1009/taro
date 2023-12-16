import 'dart:typed_data';

import 'package:quiver/cache.dart';
import 'package:quiver/core.dart';

typedef MemoryCache = ({
  Uint8List bytes,
  DateTime? expireAt,
});

class MemoryLoader {
  MemoryLoader({
    this.maximumSize,
  });

  final int? maximumSize;
  late final _cache = MapCache<int, MemoryCache>.lru(
    maximumSize: maximumSize,
  );

  Future<Uint8List?> load({
    required String url,
  }) async {
    final key = hashObjects([url]);
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
  }

  Future<void> save({
    required String url,
    required Uint8List bytes,
    DateTime? expireAt,
  }) async {
    final key = hashObjects([url]);
    await _cache.set(
      key,
      (
        bytes: bytes,
        expireAt: expireAt,
      ),
    );
  }
}
