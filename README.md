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

Here's a basic example of how to use `Taro`:

```dart
Future<void> main() async {
  // load image as byte arrays
  final Uint8List bytes = await Taro.instance.loadBytes(
    'https://example.com/image',
    headers: {
      'custom-header': 'value',
    },
  );

  // load image as TaroImage
  final TaroImage imageProvider = taro.loadImageProvider(
    'https://example.com/image',
    headers: {
      'custom-header': 'value',
    },
  );
}
```

When using it as a widget, use `TaroWidget`.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taro demo'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 200,
              height: 200,
              child: TaroWidget(
                url: 'https://example.com/image.jpg',
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                errorBuilder: (context, url, error, stackTrace) {
                  log('Image $url failed to load.');
                  log('error: $error');
                  log('stackTrace: $stackTrace');
                  return const Center(
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Depend libraries

- [image](https://pub.dev/packages/image)
- [http](https://pub.dev/packages/http)
- [js](https://pub.dev/packages/js)
- [path_provider](https://pub.dev/packages/path_provider)
- [quiver](https://pub.dev/packages/quiver)
