import 'dart:typed_data';

import 'package:taro/src/taro_resizer.dart';

/// Load [Uint8List] from storage.
Future<Uint8List?> load({
  required String filename,
  required TaroResizeOption resizeOption,
}) async =>
    throw UnimplementedError();

/// Save [Uint8List] to storage.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  required DateTime? expireAt,
  required TaroResizeOption resizeOption,
}) async =>
    throw UnimplementedError();
