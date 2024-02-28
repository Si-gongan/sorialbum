import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';
import '../helpers/storage_helper.dart';
import '../helpers/api_service.dart';
import '../helpers/utils.dart';

class SearchImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);
  final Rxn<List<String>> _queries = Rxn<List<String>>([]);

  // index of current viewing image
  final RxInt _index = 0.obs;

  // searching state
  final Rx _state = 'initial'.obs; // 'initial', 'loading', 'displayed'

  List<LocalImage>? get images => _images.value;
  List<String>? get queries => _queries.value;
  int get index => _index.value;
  String get state => _state.value;

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
    setState('loading');

    if (query.isEmpty) {
      clearSearchImages();
      setState('initial');
    } else {
      addSearchHistory(query);

      List<LocalImage> images = await dbHelper.getAllImages();
      // 유사도 기반 정렬
      List<double> queryVec = await ApiService.fetchTextEmbedding(query);
      final similarityScores = images.map((image) {
        final imageVec = image.vector;
        return {
          'image': image,
          'similarity': cosineSimilarity(queryVec, imageVec),
        };
      }).toList();
      similarityScores.sort((a, b) =>
          (b['similarity'] as double).compareTo(a['similarity'] as double));
      final queriedImages =
          similarityScores.map((e) => e['image'] as LocalImage).toList();

      if (queriedImages.isEmpty) {
        clearSearchImages();
        setState('displayed');
      } else {
        _images.value = queriedImages;
        _images.refresh();
        setState('displayed');
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
    searchHistoryManager.clearSearchHistory();
  }

  void addSearchHistory(String query) {
    _queries.value?.add(query);
    _queries.refresh();
    searchHistoryManager.saveSearchQuery(query);
  }

  void setState(String state) {
    _state.value = state;
    _state.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void clearSearchImages() {
    _images.value?.clear();
    _images.refresh();
  }

  void updateImage(LocalImage updatedImage) {
    int index = _images.value!
        .indexWhere((image) => image.assetPath == updatedImage.assetPath);
    if (index != -1) {
      _images.value![index] = updatedImage;
      _images.refresh();
    }
  }

  void updateImages(List<LocalImage> updatedImages) {
    for (LocalImage updatedImage in updatedImages) {
      int index = _images.value!
          .indexWhere((image) => image.assetPath == updatedImage.assetPath);
      if (index != -1) {
        _images.value![index] = updatedImage;
      }
    }
    _images.refresh();
  }

  void removeImage(LocalImage targetImage) {
    _images.value!
        .removeWhere((image) => image.assetPath == targetImage.assetPath);
    _images.refresh();
  }
}
