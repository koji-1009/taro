import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:taro/taro.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taro demo'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 100,
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Image $index'),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: TaroWidget(
                    url: 'https://picsum.photos/id/$index/100/100',
                    builder: (context, url, imageProvider, type) {
                      log('Image $index loaded from $type');
                      return Image(
                        image: imageProvider,
                      );
                    },
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    errorBuilder: (context, url, error) {
                      log('Image $index failed to load. error: $error');
                      return const Center(
                        child: Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
