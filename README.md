# Taro

`Taro` is a library for loading data from network and saving it to storage to speed up data loading.
By using `TaroImage`, you can also use the memory cache by CacheImage of Flutter.

This library aims to be easy to use and maintain by reducing the amount of dependent libraries and code.

## Features

- Load image as byte arrays or as `TaroImage` object.
- Set custom headers for GET requests.
- Check the max age of the data.
- Reduce the size of the data by resizing the image.

## Usage

Here's a basic example of how to use Taro:

```dart
final taro = Taro.instance;

final Uint8List bytes = await taro.loadBytes(
  'https://example.com/image',
  headers: {
    'custom-header': 'value',
  },
  checkMaxAgeIfExist: true,
);

final TaroImage imageProvider = taro.loadImageProvider(
  'https://example.com/image',
  headers: {
    'custom-header': 'value',
  },
  checkMaxAgeIfExist: true,
);
```

## Depend libraries

- [image](https://pub.dev/packages/image)
- [http](https://pub.dev/packages/http)
- [js](https://pub.dev/packages/js)
- [path_provider](https://pub.dev/packages/path_provider)
- [quiver](https://pub.dev/packages/quiver)
