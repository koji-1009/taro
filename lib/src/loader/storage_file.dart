import 'dart:convert';
import 'dart:typed_data';

import 'package:taro/src/taro_resizer.dart';

typedef StorageFile = ({
  Uint8List bytes,
  CacheInfo info,
});

/// `CacheInfo` is a class that manages the cache information for a `StorageFile`.
class CacheInfo {
  /// Creates a new instance of `CacheInfo`.
  /// The [expireAt] parameter sets the expiration date of the cache.
  const CacheInfo({
    required this.contentType,
    required this.expireAt,
    required this.resizeMode,
    this.maxWidth,
    this.maxHeight,
  });

  /// The content type of the cache.
  final String contentType;

  /// The expiration date of the cache.
  final DateTime? expireAt;

  /// The resize mode of the cache.
  final TaroResizeMode resizeMode;

  /// The maximum width of the cache.
  final int? maxWidth;

  /// The maximum height of the cache.
  final int? maxHeight;

  /// Creates a new instance of `CacheInfo` from a JSON string.
  factory CacheInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return CacheInfo(
      contentType: json['contentType'] as String,
      expireAt: json['expireAt'] == null
          ? null
          : DateTime.parse(json['expireAt'] as String),
      resizeMode: TaroResizeMode.values.firstWhere(
          (element) => element.name == json['resizeMode'],
          orElse: () => TaroResizeMode.skip),
      maxWidth: json['maxWidth'] as int?,
      maxHeight: json['maxHeight'] as int?,
    );
  }

  /// Converts the `CacheInfo` object to a JSON string.
  String toJson() => jsonEncode({
        'contentType': contentType,
        'expireAt': expireAt?.toUtc().toIso8601String(),
        'resizeMode': resizeMode.name,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });
}
