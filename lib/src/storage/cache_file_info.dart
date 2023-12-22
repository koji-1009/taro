import 'dart:convert';

/// The cache file information which saved in storage.
class CacheFileInfo {
  const CacheFileInfo({
    required this.contentType,
    required this.expireAt,
  });

  /// The content type of the cache.
  final String contentType;

  /// The expiration date of the cache.
  final DateTime? expireAt;

  factory CacheFileInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return CacheFileInfo(
      contentType: json['content_type'] as String,
      expireAt: json['expire_at'] == null
          ? null
          : DateTime.parse(json['expire_at'] as String),
    );
  }

  String toJson() => jsonEncode({
        'content_type': contentType,
        'expire_at': expireAt?.toUtc().toIso8601String(),
      });
}
