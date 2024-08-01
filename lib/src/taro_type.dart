/// The [TaroResizeOption] is used to determine how images are resized and saved.
/// Please refer to [https://pub.dev/packages/image] for supported formats.
sealed class TaroResizeOption {
  const TaroResizeOption();
}

/// The image is not resized, saved original size and format.
class TaroResizeOptionSkip extends TaroResizeOption {
  const TaroResizeOptionSkip();
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
typedef TaroHeaderOption = ({
  /// If true, the method checks the cache-control: max-age.
  bool checkMaxAgeIfExist,

  /// If true, the method throws an exception if the max-age header is invalid.
  bool ifThrowMaxAgeHeaderError,
});
