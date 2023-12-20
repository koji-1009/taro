import 'dart:typed_data';

import 'package:taro/src/loader/storage_file.dart';

/// Loads a `StorageFile` with the provided filename.
///
/// The [filename] parameter is the name of the file to load.
Future<StorageFile?> load({
  required String filename,
}) async =>
    throw UnimplementedError();

/// Saves the provided bytes as a `StorageFile` with the provided filename and content type.
///
/// The [expireAt] parameter determines when the file should expire.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  DateTime? expireAt,
}) async =>
    throw UnimplementedError();
