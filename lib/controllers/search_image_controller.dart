import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';
import '../helpers/storage_helper.dart';
// import '../helpers/api_service.dart';
// import '../helpers/utils.dart';

class SearchImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);
  List<LocalImage> _sortedImages = [];
  List<LocalImage> _filteredImages = [];

  final Rxn<List<String>> _queries = Rxn<List<String>>([]);

  // index of current viewing image
  final RxInt _index = 0.obs;

  // result type
  final Rx _type = 'filtered'.obs; // 'sorted', 'filtered'

  // searching state
  final Rx _state = 'initial'.obs; // 'initial', 'loading', 'displayed'

  List<LocalImage>? get images => _images.value;
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

  void setImages() {
    _images.value = _type.value == 'sorted' ? _sortedImages : _filteredImages;
    _images.refresh();
  }

  void queryImages(String query) async {
    setState('loading');

    if (query.isEmpty) {
      clearSearchImages();
      setState('initial');
    } else {
      addSearchHistory(query);

      /////////////////////////////////////
      //   2024.05.22. 유사도 기반 서칭 제외  //
      /////////////////////////////////////
  
      // 유사도 기반 정렬
      // List<LocalImage> allImages = await dbHelper.getAllImages();
      // List<double> queryVec = await ApiService.fetchTextEmbedding(query);
      // final similarityScores = allImages.map((image) {
      //   final imageVec = image.vector;
      //   return {
      //     'image': image,
      //     'similarity': cosineSimilarity(queryVec, imageVec),
      //   };
      // }).toList();
      // similarityScores.sort((a, b) =>
      //     (b['similarity'] as double).compareTo(a['similarity'] as double));
      // final sortedImages =
      //     similarityScores.map((e) => e['image'] as LocalImage).toList();

      // 키워드 필터링
      List<LocalImage> filteredImages =
          await dbHelper.searchImagesByKeyword(query);

      // _sortedImages = sortedImages;
      _filteredImages = filteredImages;
      setImages();
      
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
    setImages();
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
    // int sIndex = _sortedImages
    //     .indexWhere((image) => image.assetPath == updatedImage.assetPath);
    // if (sIndex != -1) {
    //   _sortedImages[sIndex] = updatedImage;
    // }

    int fIndex = _filteredImages
        .indexWhere((image) => image.assetPath == updatedImage.assetPath);
    if (fIndex != -1) {
      _filteredImages[fIndex] = updatedImage;
    }
    setImages();
  }

  void updateImages(List<LocalImage> updatedImages) {
    for (LocalImage updatedImage in updatedImages) {
      // int sIndex = _sortedImages
      //     .indexWhere((image) => image.assetPath == updatedImage.assetPath);
      // if (sIndex != -1) {
      //   _sortedImages[sIndex] = updatedImage;
      // }
      int fIndex = _filteredImages
          .indexWhere((image) => image.assetPath == updatedImage.assetPath);
      if (fIndex != -1) {
        _filteredImages[fIndex] = updatedImage;
      }
    }
    setImages();
  }

  void removeImage(LocalImage targetImage) {
    // _sortedImages
    //     .removeWhere((image) => image.assetPath == targetImage.assetPath);
    _filteredImages
        .removeWhere((image) => image.assetPath == targetImage.assetPath);
    if (_index.value == (_type.value == 'sorted' ? _sortedImages.length : _filteredImages.length)) {
      _index.value = _index.value - 1;
    }
    setImages();
  }
}
