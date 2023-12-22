import 'dart:convert';

import 'package:taro/src/taro_resizer.dart';

/// The cache file information which saved in storage.
class CacheFileInfo {
  const CacheFileInfo({
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

  factory CacheFileInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return CacheFileInfo(
      contentType: json['content_type'] as String,
      expireAt: json['expire_at'] == null
          ? null
          : DateTime.parse(json['expire_at'] as String),
      resizeMode: TaroResizeMode.values.firstWhere(
        (element) => element.name == json['resize_mode'],
        orElse: () => TaroResizeMode.skip,
      ),
      maxWidth: json['max_width'] as int?,
      maxHeight: json['max_height'] as int?,
    );
  }

  String toJson() => jsonEncode({
        'content_type': contentType,
        'expire_at': expireAt?.toUtc().toIso8601String(),
        'resize_mode': resizeMode.name,
        'max_width': maxWidth,
        'max_height': maxHeight,
      });
}
