import 'dart:convert';
import 'dart:typed_data';

typedef StorageFile = ({
  Uint8List bytes,
  CacheInfo info,
});

class CacheInfo {
  const CacheInfo({
    required this.expireAt,
  });

  final DateTime? expireAt;

  factory CacheInfo.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return CacheInfo(
      expireAt:
          json['expireAt'] != null ? DateTime.parse(json['expireAt']) : null,
    );
  }

  String toJson() => jsonEncode({
        'expireAt': expireAt?.toUtc().toIso8601String(),
      });
}
