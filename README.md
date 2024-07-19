# Taro

`Taro` is a library for loading data from network and saving it to storage to speed up data loading.
By using `TaroImage`, you can also use the memory cache by CacheImage of Flutter.

This library aims to be easy to use and maintain by reducing the amount of dependent libraries and code.

## Demo

The demo application is available at [GitHub Pages](https://koji-1009.github.io/taro/).

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

### Use another http client

If you want to use another http client, like [http](https://pub.dev/packages/http) or [dio](https://pub.dev/packages/dio), you can create a custom `TaroHttpClient`.

#### http

```dart
class HttpHttp implements TaroHttpClient {
  const HttpHttp({
    this.timeout = const Duration(
      seconds: 180,
    ),
  });

  final Duration timeout;

  @override
  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
    StreamController<ImageChunkEvent>? chunkEvents,
  }) async {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(timeout);
    return (
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
      reasonPhrase: response.reasonPhrase,
      contentLength: response.contentLength,
      headers: response.headers,
      isRedirect: response.isRedirect,
    );
  }
}
```

Then, create a `Taro` instance with the custom http client.

```dart
Taro.instance.networkLoader = TaroLoaderNetwork(
  client: const HttpHttp(),
);
```

#### dio

```dart
class DioHttp implements TaroHttpClient {
  const DioHttp({
    required this.dio,
  });

  final Dio dio;

  @override
  Future<TaroHttpResponse> get({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    // Fetch data via dio
    final response = await dio.getUri<Uint8List>(
      uri,
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );
    final data = response.data ?? Uint8List(0);
    return (
      statusCode: response.statusCode!,
      bodyBytes: data,
      reasonPhrase: response.statusMessage,
      contentLength: data.length,
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(';')),
      ),
      isRedirect: response.isRedirect,
    );
  }
}
```

Then, create a `Taro` instance with the custom http client.

```dart
Taro.instance.networkLoader = TaroLoaderNetwork(
  client: DioHttp(
    dio: Dio()
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10),
  ),
);
```

## Cache directory

If a native cache directory exists, such as Android or iOS, use [path_provider](https://pub.dev/packages/path_provider) to get the `Application Cache directory`. For web, use [Cache API](https://developer.mozilla.org/en-US/docs/Web/API/Cache) to save the cache.

## Depend libraries

- [clock](https://pub.dev/packages/clock)
  - Get current time and mock time
- [crypto](https://pub.dev/packages/crypto)
  - Get persistent file name from URL and options
- [image](https://pub.dev/packages/image)
  - Resize image
- [path_provider](https://pub.dev/packages/path_provider)
  - Get application cache directory
