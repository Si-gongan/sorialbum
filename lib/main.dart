import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'screens/home.dart';
import 'screens/search.dart';
import 'screens/image_detail.dart';
import 'screens/albums.dart';
import 'screens/album.dart';

import 'bindings/bindings.dart';
import 'helpers/utils.dart';

void main() async {
  await GetStorage.init();

  tz.initializeTimeZones();

  runApp(GetMaterialApp(
    unknownRoute:
        GetPage(name: '/notfound', page: () => const Text('Unknown Page')),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => Home(), binding: LocalImagesBinding()),
      GetPage(
          name: '/search',
          page: () => Search(),
          binding: SearchImagesBinding()),
      GetPage(
          name: '/image_detail',
          page: () => ImageDetail(),
          binding: AllImagesBinding()),
      GetPage(
          name: '/albums',
          page: () => const Albums(),
          binding: UploadBinding()),
      GetPage(
          name: '/album', page: () => const Album(), binding: UploadBinding()),
    ],
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale('en'), // English
      Locale('ko'), // Korean
    ],
  ));
}
