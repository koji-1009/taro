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

  String toJson() => jsonEncode({
        'contentType': contentType,
        'expireAt': expireAt?.toUtc().toIso8601String(),
        'resizeMode': resizeMode.name,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });
}
