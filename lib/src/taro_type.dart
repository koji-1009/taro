/// [TaroRequestOption] is used to configure the options for a resizing request.
typedef TaroResizeOption = ({
  /// The resize mode of the image.
  TaroResizeMode mode,

  /// The maximum width of the image. If null, the width is not limited.
  int? maxWidth,

  /// The maximum height of the image. If null, the height is not limited.
  int? maxHeight,
});

/// The [TaroResizeMode] enum is used to determine how images are resized.
/// Please refer to [https://pub.dev/packages/image] for supported formats.
enum TaroResizeMode {
  /// The image is not resized.
  skip,

  /// The image is resized to the original contentType.
  original,

  /// The image is resized to a gif.
  gif,

  /// The image is resized to a jpg.
  jpeg,

  /// The image is resized to a png.
  png,

  /// The image is resized to a bmp.
  bmp,

  /// The image is resized to a ico.
  ico,

  /// The image is resized to a tiff.
  tiff,
}

/// [TaroHeaderOption] is used to configure the options for a header request.
typedef TaroHeaderOption = ({
  /// If true, the method checks the cache-control: max-age.
  bool checkMaxAgeIfExist,

  /// If true, the method throws an exception if the max-age header is invalid.
  bool ifThrowMaxAgeHeaderError,
});
