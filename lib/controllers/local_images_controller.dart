import 'package:get/get.dart';
import '../models/image.dart';
import '../helpers/db_helper.dart';
import 'package:intl/intl.dart';

class LocalImagesController extends GetxController {
  final Rxn<List<LocalImage>> _images = Rxn<List<LocalImage>>([]);

  final RxInt _index = 0.obs;

  final Rx _state = 'initial'.obs; // 'initial', 'saving', 'fetching'

  List<LocalImage>? get images => _images.value;
  int get index => _index.value;

  final dbHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  fetchImages() async {
    final fetchedImages = await dbHelper.getAllImages();
    _images.value = fetchedImages;
    _images.refresh();
  }

  void setCurrentIndex(int index) {
    _index.value = index;
  }

  void addImage(LocalImage image) {
    if (_images.value == null) {
      _images.value = [image];
    } else {
      // 이미지 리스트가 비어있지 않은 경우
      // 삽입될 적절한 위치를 찾기 위해 이미지 리스트를 순회합니다.
      int insertIndex = _images.value!.indexWhere(
          (existingImage) => existingImage.createdAt.isBefore(image.createdAt));
      if (insertIndex == -1) {
        // 모든 이미지가 새 이미지보다 이전 날짜인 경우, 리스트의 끝에 추가합니다.
        _images.value!.add(image);
      } else {
        // 새 이미지가 들어갈 위치를 찾은 경우, 해당 위치에 삽입합니다.
        _images.value!.insert(insertIndex, image);
      }
    }
    _images.refresh();
  }

  void addImages(List<LocalImage> newImages) {
    // List.from을 사용하여 newImages의 깊은 복사본을 생성합니다.
    List<LocalImage> newImagesCopy = List<LocalImage>.from(newImages);

    if (_images.value == null) {
      // 기존 이미지 리스트가 비어있는 경우, 새 이미지들을 정렬하여 바로 할당합니다.
      _images.value = newImagesCopy..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      // 기존 이미지 리스트가 비어있지 않은 경우
      // 새 이미지들을 먼저 createdAt 기준으로 정렬합니다.
      newImagesCopy.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 정렬된 새 이미지들을 기존 리스트에 적절한 위치에 삽입합니다.
      for (LocalImage newImage in newImagesCopy) {
        int insertIndex = _images.value!.indexWhere((existingImage) =>
            existingImage.createdAt.isBefore(newImage.createdAt));
        if (insertIndex == -1) {
          // 모든 기존 이미지가 새 이미지보다 이전 날짜인 경우, 리스트의 끝에 추가합니다.
          _images.value!.add(newImage);
        } else {
          // 새 이미지가 들어갈 적절한 위치를 찾은 경우, 해당 위치에 삽입합니다.
          _images.value!.insert(insertIndex, newImage);
        }
      }
    }
    _images.refresh();
  }

  void updateImage(LocalImage updatedImage) {
    // id를 기반으로 해당 이미지를 찾습니다.
    int index =
        _images.value!.indexWhere((image) => image.assetPath == updatedImage.assetPath);
    if (index != -1) {
      _images.value![index] = updatedImage;
      _images.refresh(); // 이미지 리스트를 업데이트하고 UI에 반영하기 위해 refresh를 호출합니다.
    }
  }

  void updateImages(List<LocalImage> updatedImages) {
    for (LocalImage updatedImage in updatedImages){
      int index =
        _images.value!.indexWhere((image) => image.assetPath == updatedImage.assetPath);
      if (index != -1) {
        _images.value![index] = updatedImage;
      }
    }
    _images.refresh();
  }

  // 이미지 삭제 - id를 기반으로 이미지 찾아 삭제
  void removeImage(LocalImage targetImage) {
    _images.value!.removeWhere((image) => image.assetPath == targetImage.assetPath);
    _images.refresh();
    dbHelper.deleteImage(targetImage);
  }

  Map<String, Map<String, List<LocalImage>>> groupImagesByMonthAndDate(
      List<LocalImage> images) {
    Map<String, Map<String, List<LocalImage>>> grouped = {};
    var idx = 0;
    for (var image in images) {
      String monthKey = DateFormat('yyyy-MM').format(image.createdAt);
      String dateKey = DateFormat('yyyy-MM-dd').format(image.createdAt);

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = {};
      }
      if (!grouped[monthKey]!.containsKey(dateKey)) {
        grouped[monthKey]![dateKey] = [];
      }
      image.countId = idx++;
      grouped[monthKey]![dateKey]!.add(image);
    }
    return grouped;
  }
}
