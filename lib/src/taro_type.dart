/// The [TaroResizeOption] is used to determine how images are resized and saved.
/// Please refer to [https://pub.dev/packages/image] for supported formats.
sealed class TaroResizeOption {
  const TaroResizeOption();
}

/// The image is not resized, saved original size and format.
class TaroResizeOptionSkip extends TaroResizeOption {
  const TaroResizeOptionSkip();

  @override
  String toString() => 'skip';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaroResizeOptionSkip && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

/// The image is resized in memory, saved original size and format.
class TaroResizeOptionMemory extends TaroResizeOption {
  const TaroResizeOptionMemory({
    required this.maxWidth,
    required this.maxHeight,
  });

  /// The maximum width of the image.
  final int maxWidth;

  /// The maximum height of the image.
  final int maxHeight;

  @override
  String toString() => 'memory_${maxWidth}x$maxHeight';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaroResizeOptionMemory &&
          runtimeType == other.runtimeType &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode => Object.hash(maxWidth, maxHeight);
}

class TaroResizeOptionDisk extends TaroResizeOption {
  const TaroResizeOptionDisk({
    required this.format,
    this.maxWidth,
    this.maxHeight,
  });

  /// The format of the image.
  final TaroResizeFormat format;

  /// The maximum width of the image. If null, the width is not limited.
  final int? maxWidth;

  /// The maximum height of the image. If null, the height is not limited.
  final int? maxHeight;

  @override
  String toString() =>
      'disk_${format.name}_${maxWidth ?? 'auto'}x${maxHeight ?? 'auto'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaroResizeOptionDisk &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode => Object.hash(format, maxWidth, maxHeight);
}

enum TaroResizeFormat {
  /// The original format of the image.
  original,

  /// The image is saved as a gif.
  gif,

  /// The image is saved as a jpeg.
  jpeg,

  /// The image is saved as a png.
  png,

  /// The image is saved as a bmp.
  bmp,

  /// The image is saved as an icon.
  ico,

  /// The image is saved as a tiff.
  tiff,
}

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
