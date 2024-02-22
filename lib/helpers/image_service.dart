import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_helper.dart';
import '../models/image.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../controllers/local_images_controller.dart';
import 'package:exif/exif.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FileManager _fileManager = FileManager();

  final dbHelper = DatabaseHelper();
  final controller = Get.find<LocalImagesController>();

  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<List<XFile>?> pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images;
  }

  Future<XFile?> takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future<void> saveImageAndMetadata(XFile imageFile) async {
    List<double> embeddingVector = [];
    String caption = "Sample Caption";
    List<String> tags = ["tag1", "tag2"];

    final localImageFilePath = await _fileManager.saveImage(imageFile);

    // LocalImage 객체 생성
    final localImage = LocalImage(localImageFilePath)
      ..vector = embeddingVector
      ..caption = caption
      ..generalTags = tags;

    // 데이터베이스에 저장
    await dbHelper.insertImage(localImage);
    controller.addImage(localImage); // 컨트롤러의 이미지 리스트 업데이트
  }

  Future<void> saveImagesAndMetadata(List<XFile> imageFiles) async {
    List<LocalImage> localImages = [];

    for (XFile imageFile in imageFiles) {
      List<double> embeddingVector = [];
      String caption = "Sample Caption";
      List<String> tags = ["tag1", "tag2"];

      // FileManager를 사용하여 이미지 파일을 저장하고 로컬 경로를 가져옵니다.
      final localImageFilePath = await _fileManager.saveImage(imageFile);

      // LocalImage 객체를 생성하고 메타데이터를 설정합니다.
      final localImage = LocalImage(localImageFilePath)
        ..vector = embeddingVector
        ..caption = caption
        ..generalTags = tags;

      // 생성된 LocalImage 객체를 로컬 리스트에 추가합니다.
      localImages.add(localImage);
    }

    // 데이터베이스에 모든 LocalImage 객체를 한 번에 삽입합니다.
    // 이를 위해 DatabaseHelper 클래스에 적절한 메서드가 구현되어 있어야 합니다.
    await dbHelper.insertImages(localImages);

    // 컨트롤러의 이미지 리스트를 업데이트합니다.
    controller.addImages(localImages);
  }
}

class FileManager {
  Future<String> saveImage(XFile pickedFile) async {
    final File imageFile = File(pickedFile.path);

    readExifFromImageFile(imageFile);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedPath = path.join(directory.path, fileName);
    await imageFile.copy(savedPath);
    return savedPath;
  }

  Future<void> readExifFromImageFile(File imageFile) async {
    final data = await readExifFromBytes(await imageFile.readAsBytes());
    
    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    }

    for (final entry in data.entries) {
      print('${entry.key}: ${entry.value}');
    }

    // 예를 들어, GPS 정보를 조회
    if (data.containsKey('GPS GPSLatitude') && data.containsKey('GPS GPSLongitude')) {
      print('Latitude: ${data['GPS GPSLatitude']}');
      print('Longitude: ${data['GPS GPSLongitude']}');
    }
  }
}