import 'dart:typed_data';

/// Load [Uint8List] from storage.
Future<Uint8List?> load({
  required String filename,
}) async =>
    throw UnimplementedError();

/// Save [Uint8List] to storage.
Future<void> save({
  required String filename,
  required Uint8List bytes,
  required String contentType,
  required DateTime? expireAt,
}) async =>
    throw UnimplementedError();
