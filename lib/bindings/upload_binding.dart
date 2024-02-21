import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class UploadBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(UploadController());
  }
}