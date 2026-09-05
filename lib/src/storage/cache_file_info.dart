import 'dart:convert';

import 'package:flutter/foundation.dart';

/// The cache file information which saved in storage.
@immutable
class CacheFileInfo {
  const CacheFileInfo({
    required this.contentType,
    required this.expireAt,
  });

  /// The content type of the cache.
  final String contentType;

  /// The expiration date of the cache.
  final DateTime? expireAt;

  /// Restores a [CacheFileInfo] from the string written by [toJson].
  ///
  /// Throws a [FormatException] if the string is not a cache file info, so
  /// that a corrupted cache file surfaces as an [Exception] instead of an
  /// [Error].
  factory CacheFileInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr);
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        '[taro][storage] Cache file info is not a JSON object',
        jsonStr,
      );
    }

    final contentType = json['content_type'];
    if (contentType is! String) {
      throw FormatException(
        '[taro][storage] Cache file info has no content_type',
        jsonStr,
      );
    }

    final expireAt = json['expire_at'];
    if (expireAt is! String?) {
      throw FormatException(
        '[taro][storage] Cache file info has an invalid expire_at',
        jsonStr,
      );
    }

    return CacheFileInfo(
      contentType: contentType,
      expireAt: DateTime.tryParse(expireAt ?? ''),
    );
  }

  String toJson() => jsonEncode({
        'content_type': contentType,
        'expire_at': expireAt?.toUtc().toIso8601String(),
      });
}
