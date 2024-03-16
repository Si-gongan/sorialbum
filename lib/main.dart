import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'helpers/firestore_helper.dart';
import 'firebase_options.dart';

import 'screens/home.dart';
import 'screens/search.dart';
import 'screens/image_detail.dart';
import 'screens/albums.dart';
import 'screens/album.dart';

import 'bindings/bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirestoreHelper.createUserDocumentIfNeeded();

  tz.initializeTimeZones();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    showSemanticsDebugger: false,
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
          page: () => const ImageDetail(),
          binding: AllImagesBinding()),
      GetPage(
          name: '/albums',
          page: () => const Albums(),
          binding: UploadBinding()),
      GetPage(
          name: '/album', page: () => const Album(), binding: UploadBinding()),
    ],
    theme: ThemeData(
      useMaterial3: true,

      // Define the default brightness and colors.
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        // ···
        brightness: Brightness.light,
      ),

      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
        // ···
        // titleLarge: GoogleFonts.oswald(
        //   fontSize: 30,
        //   fontStyle: FontStyle.italic,
        // ),
        // bodyMedium: GoogleFonts.merriweather(),
        // displaySmall: GoogleFonts.pacifico(),
      ),
    ),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'), // English
      Locale('ko'), // Korean
    ],
  ));
}
