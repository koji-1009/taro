# Taro

Taro is a Flutter library for loading data from various sources. It provides a set of classes and methods for loading data from network, memory, and storage.

## Features

- Load image as byte arrays or as `MemoryImage` objects.
- Set custom headers for GET requests.
- Check the max age of the data.

## Usage

Here's a basic example of how to use Taro:

```dart
final taro = Taro.instance;

final bytes = await taro.loadBytes(
  'https://example.com/image',
  headers: {
    'custom-header': 'value',
  },
  checkMaxAgeIfExist: true,
);

final imageProvider = await taro.loadImageProvider(
  'https://example.com/image',
  headers: {
    'custom-header': 'value',
  },
  checkMaxAgeIfExist: true,
);
```
