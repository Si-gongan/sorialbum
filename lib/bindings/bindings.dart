import 'package:get/get.dart';
import '../controllers/upload_controller.dart';
import '../controllers/local_images_controller.dart';
import '../controllers/search_image_controller.dart';

class UploadBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(UploadController());
  }
}

class LocalImagesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LocalImagesController());
  }
}

class SearchImagesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SearchImagesController());
  }
}

class AllImagesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LocalImagesController());
    Get.put(SearchImagesController());
  }
}