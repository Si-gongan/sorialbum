import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';

class LocalImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);

  final RxInt _index = 0.obs;

  List<LocalImage>? get images => _images.value;
  int get index => _index.value;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  fetchImages() async {
    final dbHelper = DatabaseHelper();
    final fetchedImages = await dbHelper.getAllImages();
    _images.value = fetchedImages;
    _images.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void addImage(LocalImage image) {
    _images.value?.add(image);
    _images.refresh();
  }

  void addImages(List<LocalImage> newImages) {
    _images.value?.addAll(newImages);
    _images.refresh();
  }

  void updateImage(LocalImage updatedImage) {
    // id를 기반으로 해당 이미지를 찾습니다.
    int index = _images.value!.indexWhere((image) => image.id == updatedImage.id);
    if (index != -1) {
      _images.value![index] = updatedImage;
      _images.refresh(); // 이미지 리스트를 업데이트하고 UI에 반영하기 위해 refresh를 호출합니다.
    }
  }

  // 이미지 삭제 - id를 기반으로 이미지 찾아 삭제
  void removeImage(int id) {
    _images.value!.removeWhere((image) => image.id == id);
  }
}
