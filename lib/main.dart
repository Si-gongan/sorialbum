import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/home.dart';
import 'screens/search.dart';
import 'screens/image_detail.dart';
import 'screens/albums.dart';
import 'screens/album.dart';

import 'bindings/upload_binding.dart';

void main() async {
  runApp(GetMaterialApp(
    unknownRoute: GetPage(
        name: '/notfound', page: () => const Text('Unknown Page')),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => const Home()),
      GetPage(name: '/search', page: () => const Search()),
      GetPage(name: '/image_detail', page: () => const ImageDetail()),
      GetPage(name: '/albums', page: () => const Albums(), binding: UploadBinding()),
      GetPage(name: '/album', page: () => const Album(), binding: UploadBinding()),
    ],
  ));
}
