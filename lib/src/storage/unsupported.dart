import 'dart:typed_data';

import 'package:taro/src/loader/storage_file.dart';

Future<StorageFile?> load({
  required String filename,
}) async =>
    throw UnimplementedError();

Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  DateTime? expireAt,
}) async =>
    throw UnimplementedError();
