import 'package:path_provider/path_provider.dart';

class AppConfig {
  static String? appDocumentsDirectory;

  static Future<void> initializeApp() async {
    final directory = await getApplicationDocumentsDirectory();
    AppConfig.appDocumentsDirectory = directory.path;
  }
}