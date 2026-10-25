import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:taro/src/storage/shared.dart' as storage;
import 'package:taro/src/taro_exception.dart';

/// The [TaroLoaderStorage] class is used to load and save data from storage.
class TaroLoaderStorage {
  /// Creates a [TaroLoaderStorage].
  const TaroLoaderStorage();

  /// Loads the data for the provided URL and request headers from storage.
  /// Returns a Future that completes with the data.
  Future<Uint8List?> load({
    required String url,
    Map<String, String> headers = const {},
  }) async {
    try {
      return await storage.load(
        filename: _filename(url: url, headers: headers),
      );
    } on Exception catch (exception) {
      throw TaroStorageException(
        exception: exception,
      );
    }
  }

  /// Saves the data for the provided URL and request headers to storage.
  Future<void> save({
    required String url,
    Map<String, String> headers = const {},
    required Uint8List bytes,
    required String contentType,
    required DateTime? expireAt,
  }) async {
    try {
      return await storage.save(
        filename: _filename(url: url, headers: headers),
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

  /// Returns the file name of the cache for the request.
  /// The response can differ by request headers (e.g. per-user images with
  /// an authorization header), so the headers are part of the name.
  String _filename({
    required String url,
    required Map<String, String> headers,
  }) {
    if (headers.isEmpty) {
      // The same name as when only the URL was used, so existing caches of
      // requests without headers stay valid.
      return '${sha256.convert(utf8.encode(url))}';
    }

    // Header names are case-insensitive and their order does not matter.
    final entries = [
      for (final entry in headers.entries)
        [entry.key.toLowerCase(), entry.value],
    ]..sort((a, b) {
        final byName = a[0].compareTo(b[0]);
        return byName != 0 ? byName : a[1].compareTo(b[1]);
      });
    return '${sha256.convert(utf8.encode(jsonEncode([url, entries])))}';
  }
}
