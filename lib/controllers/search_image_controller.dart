import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';
import '../helpers/storage_helper.dart';

class SearchImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);
  final Rxn<List<String>> _queries = Rxn<List<String>>([]);

  // index of current viewing image
  final RxInt _index = 0.obs;

  // true only after the query entered
  final Rx _result = false.obs;

  List<LocalImage>? get images => _images.value;
  List<String>? get queries => _queries.value;
  int get index => _index.value;
  bool get result => _result.value;

  final dbHelper = DatabaseHelper();
  final searchHistoryManager = SearchHistoryManager();

  @override
  void onInit() {
    super.onInit();
    fetchSearchHistory();
  }

  @override
  void onClose() {
    // 페이지를 벗어날 때 호출됩니다. 검색 결과를 초기화합니다.
    clearSearchImages();
    super.onClose();
  }

  void queryImages(String query) async {
    // add query logic
    if (query.isEmpty) {
      setResult(false);
      clearSearchImages();
    } else {
      setResult(true);
      addSearchHistory(query);

      final queriedImages = await dbHelper.getAllImages();
      print('queried!');
      print(queriedImages);

      if (queriedImages.isEmpty) {
        clearSearchImages();
      } else {
        // TODO : image search logic
        _images.value = queriedImages;
        _images.refresh();
      }
    }
  }

  void fetchSearchHistory() {
    _queries.value = searchHistoryManager.getSearchHistory();
    _queries.refresh();
  }

  void clearSearchHistory() {
    _queries.value?.clear();
    _queries.refresh();
    clearSearchHistory();
  }

  void addSearchHistory(String query) {
    _queries.value?.add(query);
    _queries.refresh();
    searchHistoryManager.saveSearchQuery(query);
  }

  void setResult(bool result) {
    _result.value = result;
    _result.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void clearSearchImages() {
    _images.value?.clear();
    _images.refresh();
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
    int index =
        _images.value!.indexWhere((image) => image.id == updatedImage.id);
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
