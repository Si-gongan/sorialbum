import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';

class SearchImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);

  final RxInt _index = 0.obs;

  final Rx _result = false.obs;

  List<LocalImage>? get images => _images.value;
  int get index => _index.value;
  bool get result => _result.value;

  final dbHelper = DatabaseHelper();

  @override
  void onClose() {
    // 페이지를 벗어날 때 호출됩니다. 검색 결과를 초기화합니다.
    clearSearchImages();
    super.onClose();
  }

  queryImages(String query) async {
    // add query logic
    if (query.isEmpty) {
      setResult(false);
      clearSearchImages();
    } else {
      setResult(true);
      final queriedImages = await dbHelper.getAllImages();
      if (queriedImages.isEmpty) {
        clearSearchImages();
      } else {
        // TODO : image search logic
        _images.value = queriedImages.reversed.toList();
        _images.refresh();
      }
    }
  }

  void clearSearchImages() {
    _images.value?.clear();
    _images.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void setResult(bool result) {
    _result.value = result;
    _result.refresh();
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
