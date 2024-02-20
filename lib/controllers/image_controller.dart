import 'package:get/get.dart';
import '../models/image.dart';

class GalleryController extends GetxController {
  var images = <Image>[].obs;
  var sortedImages = <Image>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadImages();
  }

  void loadImages({int page = 1, int pageSize = 50}) {
    // maybe need pagination logic
    List<Image> dummyInitImages = [
      Image(1, 'https://picsum.photos/id/101/600/400'),
      Image(2, 'https://picsum.photos/id/102/600/400'),
      Image(3, 'https://picsum.photos/id/103/600/400'),
      Image(4, 'https://picsum.photos/id/104/600/400'),
      Image(5, 'https://picsum.photos/id/105/600/400'),
      Image(6, 'https://picsum.photos/id/106/600/400'),
      Image(7, 'https://picsum.photos/id/107/600/400'),
      Image(8, 'https://picsum.photos/id/108/600/400'),
      Image(9, 'https://picsum.photos/id/109/600/400')
    ];
    images.assignAll(dummyInitImages);
  }

  void updateSortedImages(String query) {
    // api query logic
    List<Image> dummySortedImages = [
      Image(1, 'https://picsum.photos/id/201/600/400'),
      Image(2, 'https://picsum.photos/id/202/600/400'),
      Image(3, 'https://picsum.photos/id/203/600/400'),
      Image(4, 'https://picsum.photos/id/204/600/400'),
      Image(5, 'https://picsum.photos/id/205/600/400'),
      Image(6, 'https://picsum.photos/id/206/600/400'),
      Image(7, 'https://picsum.photos/id/207/600/400'),
      Image(8, 'https://picsum.photos/id/208/600/400'),
      Image(9, 'https://picsum.photos/id/209/600/400')
    ];
    sortedImages.assignAll(dummySortedImages);
  }

  void addImage(Image image) {
    images.add(image);
  }

  void addImages(List<Image> images_) {
    images.addAll(images_);
  }

  void removeImageById(int id) {
    images.removeWhere((img) => img.id == id);
  }

  void removeImagesByIds(List<int> ids) {
    images.removeWhere((img) => ids.contains(img.id));
  }
}
