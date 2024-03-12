import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';
import '../helpers/storage_helper.dart';
import '../helpers/api_service.dart';
import '../helpers/utils.dart';

class SearchImagesController extends GetxController {
  final Rxn<List<LocalImage>> _sortedImages = Rxn<List<LocalImage>>([]);
  final Rxn<List<LocalImage>> _filteredImages = Rxn<List<LocalImage>>([]);
  final Rxn<List<String>> _queries = Rxn<List<String>>([]);

  // index of current viewing image
  final RxInt _index = 0.obs;

  // result type
  final Rx _type = 'filtered'.obs; // 'sorted', 'filtered'

  // searching state
  final Rx _state = 'initial'.obs; // 'initial', 'loading', 'displayed'

  List<LocalImage>? get images =>
      _type.value == 'sorted' ? _sortedImages.value : _filteredImages.value;
  List<String>? get queries => _queries.value;
  int get index => _index.value;
  String get type => _type.value;
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

      // 유사도 기반 정렬
      List<LocalImage> allImages = await dbHelper.getAllImages();
      List<double> queryVec = await ApiService.fetchTextEmbedding(query);
      final similarityScores = allImages.map((image) {
        final imageVec = image.vector;
        return {
          'image': image,
          'similarity': cosineSimilarity(queryVec, imageVec),
        };
      }).toList();
      similarityScores.sort((a, b) =>
          (b['similarity'] as double).compareTo(a['similarity'] as double));
      final sortedImages =
          similarityScores.map((e) => e['image'] as LocalImage).toList();

      // 키워드 필터링
      List<LocalImage> filteredImages =
          await dbHelper.searchImagesByKeyword(query);

      _sortedImages.value = sortedImages;
      _filteredImages.value = filteredImages;
      _sortedImages.refresh();
      _filteredImages.refresh();
      setState('displayed');
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

  void setType(String type) {
    _type.value = type;
    _type.refresh();
  }

  void setState(String state) {
    _state.value = state;
    _state.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void clearSearchImages() {
    _sortedImages.value?.clear();
    _filteredImages.value?.clear();
    _sortedImages.refresh();
    _filteredImages.refresh();
  }

  void updateImage(LocalImage updatedImage) {
    int sIndex = _sortedImages.value!
        .indexWhere((image) => image.assetPath == updatedImage.assetPath);
    if (sIndex != -1) {
      _sortedImages.value![sIndex] = updatedImage;
      _sortedImages.refresh();
    }

    int fIndex = _filteredImages.value!
        .indexWhere((image) => image.assetPath == updatedImage.assetPath);
    if (fIndex != -1) {
      _filteredImages.value![fIndex] = updatedImage;
      _filteredImages.refresh();
    }
  }

  void updateImages(List<LocalImage> updatedImages) {
    for (LocalImage updatedImage in updatedImages) {
      int sIndex = _sortedImages.value!
          .indexWhere((image) => image.assetPath == updatedImage.assetPath);
      if (sIndex != -1) {
        _sortedImages.value![sIndex] = updatedImage;
      }
      int fIndex = _filteredImages.value!
          .indexWhere((image) => image.assetPath == updatedImage.assetPath);
      if (fIndex != -1) {
        _filteredImages.value![fIndex] = updatedImage;
      }
    }
    _filteredImages.refresh();
    _sortedImages.refresh();
  }

  void removeImage(LocalImage targetImage) {
    _sortedImages.value!
        .removeWhere((image) => image.assetPath == targetImage.assetPath);
    _filteredImages.value!
        .removeWhere((image) => image.assetPath == targetImage.assetPath);
    if (_index.value == (_type.value == 'sorted' ? _sortedImages.value!.length : _filteredImages.value!.length)) {
      _index.value = (_type.value == 'sorted' ? _sortedImages.value!.length : _filteredImages.value!.length)-1;
    }
    _sortedImages.refresh();
    _filteredImages.refresh();
  }
}
