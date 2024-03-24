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
    // if (!Get.isRegistered<SearchImagesController>()) {
    //   print('put!');
    //   Get.put(SearchImagesController());
    // }
    try {
      // Get.find()를 시도하여 이미 등록된 인스턴스가 있는지 확인
      Get.find<SearchImagesController>();
    } catch (e) {
      // 등록된 인스턴스가 없을 경우, 새로운 인스턴스를 생성하고 주입
      print('put!');
      Get.put(SearchImagesController());
    }
  }
}

class AllImagesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LocalImagesController());
    if (!Get.isRegistered<SearchImagesController>()) {
      print('put!');
      Get.put(SearchImagesController());
    }
  }
}