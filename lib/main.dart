import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/home.dart';
import 'screens/search.dart';
import 'screens/image_detail.dart';

void main() async {
  runApp(GetMaterialApp(
    unknownRoute: GetPage(
        name: '/notfound', page: () => Container(child: Text('Unknown Page'))),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => Home()),
      GetPage(name: '/search', page: () => Search()),
      GetPage(name: '/image_detail', page: () => ImageDetail())
    ],
  ));
}
