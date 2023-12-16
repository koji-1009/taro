import 'dart:typed_data';

enum LoaderResultType {
  network,
  memory,
  storage,
}

typedef LoaderResult = ({
  Uint8List bytes,
  LoaderResultType type,
});
