import 'dart:convert';
import 'dart:typed_data';

typedef StorageFile = ({
  Uint8List bytes,
  CacheInfo info,
});

/// `CacheInfo` is a class that manages the cache information for a `StorageFile`.
class CacheInfo {
  /// Creates a new instance of `CacheInfo`.
  /// The [expireAt] parameter sets the expiration date of the cache.
  const CacheInfo({
    required this.expireAt,
  });

  /// The expiration date of the cache.
  final DateTime? expireAt;

  /// Creates a new instance of `CacheInfo` from a JSON string.
  factory CacheInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return CacheInfo(
      expireAt:
          json['expireAt'] != null ? DateTime.parse(json['expireAt']) : null,
    );
  }

  /// Converts the `CacheInfo` object to a JSON string.
  String toJson() => jsonEncode({
        'expireAt': expireAt?.toUtc().toIso8601String(),
      });
}
