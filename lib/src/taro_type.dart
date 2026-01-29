/// [TaroHeaderOption] is used to configure the options for a header request.
class TaroHeaderOption {
  /// Creates a [TaroHeaderOption].
  const TaroHeaderOption({
    this.checkMaxAgeIfExist = false,
    this.ifThrowMaxAgeHeaderError = false,
    this.customCacheDuration,
  });

  /// If true, the method checks the cache-control: max-age.
  final bool checkMaxAgeIfExist;

  /// If true, the method throws an exception if the max-age header is invalid.
  final bool ifThrowMaxAgeHeaderError;

  /// Custom cache duration. If set, this overrides the cache-control header.
  /// Useful when the server doesn't provide cache headers or you want to enforce
  /// a specific cache policy (e.g., Duration(days: 7)).
  final Duration? customCacheDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaroHeaderOption &&
          runtimeType == other.runtimeType &&
          checkMaxAgeIfExist == other.checkMaxAgeIfExist &&
          ifThrowMaxAgeHeaderError == other.ifThrowMaxAgeHeaderError &&
          customCacheDuration == other.customCacheDuration;

  @override
  int get hashCode => Object.hash(
        checkMaxAgeIfExist,
        ifThrowMaxAgeHeaderError,
        customCacheDuration,
      );

  @override
  String toString() => 'TaroHeaderOption('
      'checkMaxAgeIfExist: $checkMaxAgeIfExist, '
      'ifThrowMaxAgeHeaderError: $ifThrowMaxAgeHeaderError, '
      'customCacheDuration: $customCacheDuration)';
}
