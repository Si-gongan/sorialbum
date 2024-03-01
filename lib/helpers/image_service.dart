import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_helper.dart';
import '../models/image.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../controllers/local_images_controller.dart';
import '../controllers/search_image_controller.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:broady_lite/helpers/utils.dart';
import 'api_service.dart';

final ImagePicker _picker = ImagePicker();

final dbHelper = DatabaseHelper();
final localImageController = Get.find<LocalImagesController>();
final searchImageController = Get.find<SearchImagesController>();

class ImageService {
  static Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  static Future<List<XFile>?> pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images;
  }

  static Future<XFile?> takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image;
  }

  static Future<void> saveImagesAndMetadata(List<XFile> pickedFiles) async {
    final List<File> imageFiles =
        await Future.wait(pickedFiles.map((file) async {
      final File imageFile = File(file.path);
      return imageFile;
    }));

    List<LocalImage> localImages = [];

    // first stage: get local path and original date

    final localImageFilePaths = await saveImages(imageFiles);
    final dateTimeOriginals = await getDateTimeOriginals(imageFiles);

    for (int i = 0; i < imageFiles.length; i++) {
      // LocalImage 객체를 생성
      final localImage = LocalImage(localImageFilePaths[i]['savedPath']!)
        ..thumbAssetPath = localImageFilePaths[i]['thumbSavedPath']
        ..createdAt =
            dateTimeOriginals[i]?.localTime ?? DateTime.now().localTime;

      // 생성된 LocalImage 객체를 로컬 리스트에 추가
      localImages.add(localImage);
    }

    // first UI update
    await dbHelper.insertImages(localImages);
    localImageController.addImages(localImages);

    // second stage: get cloud urls
    List<String> imageUrls = await ApiService.fetchImageUrls(imageFiles);

    // third stage: get tags, embeddings
    List<List<String>> tags =
        await ApiService.fetchAzureTags(imageUrls, maxNumber: 5, lang: "ko");

    List<List<double>> embeddings =
        await ApiService.fetchImageEmbeddings(imageUrls);

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].imageUrl = imageUrls[i];
      localImages[i].generalTags = tags[i];
      localImages[i].vector = embeddings[i];
    }

    // second UI update
    await dbHelper.updateImagesByMaps(localImages
        .map((e) => {
              for (var key in [
                'assetPath',
                'imageUrl',
                'generalTags',
                'vector'
              ])
                key: e.toMap()[key]
            })
        .toList());
    localImageController.updateImages(localImages);
    if (searchImageController.initialized) {
      searchImageController.updateImages(localImages);
    }

    // 4th stage: get captions
    List<String> captions = await ApiService.fetchGPTCaptions(imageFiles);

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].caption = captions[i];
    }

    // third UI update
    await dbHelper.updateImagesByMaps(localImages
        .map((e) => {
              for (var key in ['assetPath', 'caption']) key: e.toMap()[key]
            })
        .toList());
    localImageController.updateImages(localImages);
    if (searchImageController.initialized) {
      searchImageController.updateImages(localImages);
    }
    Get.snackbar(
      '이미지 캡션 생성 완료', // 제목
      '총 ${localImages.length}개의 이미지 캡션 생성이 완료되었습니다.', // 메시지
      backgroundColor: Colors.grey[800], // 배경색 설정
      colorText: Colors.white, // 텍스트 색상 설정
      snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
      margin: const EdgeInsets.all(0), // 마진 제거
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
      duration: const Duration(seconds: 4), // 지속 시간 설정
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  static Future<void> getDescription(LocalImage image) async {
    image.description = '설명을 생성중이에요...';
    localImageController.updateImage(image);
    if (searchImageController.initialized) {
      searchImageController.updateImage(image);
    }

    File imageFile = File(image.assetPath);
    final description = await ApiService.fetchImageDescription(imageFile);
    image.description = description;

    await dbHelper.updateImageByMap({
      for (var key in ['assetPath', 'description']) key: image.toMap()[key]
    });
    localImageController.updateImage(image);
    if (searchImageController.initialized) {
      searchImageController.updateImage(image);
    }
    Get.snackbar(
      '이미지 설명 생성 완료', // 제목
      '이미지의 설명 생성이 완료되었습니다.', // 메시지
      backgroundColor: Colors.grey[800], // 배경색 설정
      colorText: Colors.white, // 텍스트 색상 설정
      snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
      margin: const EdgeInsets.all(0), // 마진 제거
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
      duration: const Duration(seconds: 3), // 지속 시간 설정
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  static Future<void> getOCR(LocalImage image) async {
    image.ocr = '글자를 인식중이에요...';
    localImageController.updateImage(image);
    if (searchImageController.initialized) {
      searchImageController.updateImage(image);
    }

    File imageFile = File(image.assetPath);
    final texts = await ApiService.fetchImageOCRs([imageFile]);
    image.ocr = texts[0];

    await dbHelper.updateImageByMap({
      for (var key in ['assetPath', 'ocr']) key: image.toMap()[key]
    });
    localImageController.updateImage(image);
    if (searchImageController.initialized) {
      searchImageController.updateImage(image);
    }
    Get.snackbar(
      '이미지 글자 인식 완료', // 제목
      '이미지의 글자 인식이 완료되었습니다.', // 메시지
      backgroundColor: Colors.grey[800], // 배경색 설정
      colorText: Colors.white, // 텍스트 색상 설정
      snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
      margin: const EdgeInsets.all(0), // 마진 제거
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
      duration: const Duration(seconds: 2), // 지속 시간 설정
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  static Future<void> removeImage(LocalImage image) async {
    localImageController.removeImage(image);
    searchImageController.removeImage(image);
    await dbHelper.deleteImage(image);
  }
}

Future<List<Map<String, String>>> saveImages(List<File> imageFiles) async {
  final results = await Future.wait(imageFiles.map(saveImage));
  return results;
}

Future<Map<String, String>> saveImage(File imageFile) async {
  // 원본 저장
  final directory = await getApplicationDocumentsDirectory();
  final fileName = path.basename(imageFile.path);
  final savedPath = path.join(directory.path, fileName);
  await imageFile.copy(savedPath);

  // 썸네일 저장
  final thumbSavedPath = await createThumbnail(imageFile.path, directory.path);

  return {'savedPath': savedPath, 'thumbSavedPath': thumbSavedPath};
}

Future<String> createThumbnail(String filePath, String saveDir) async {
  final fileName = path.basenameWithoutExtension(filePath);
  final thumbFileName = 'thumb_$fileName.jpg';
  final thumbSavedPath = path.join(saveDir, thumbFileName);

  // 이미지 파일 읽기
  final imageBytes = File(filePath).readAsBytesSync();
  img.Image? image = img.decodeImage(imageBytes);

  // 섬네일 이미지 생성 (예: 너비 120px에 맞춰 크기 조정)
  img.Image thumbnail = img.copyResize(image!, width: 200);

  // JPEG 형식으로 섬네일 이미지 저장
  File(thumbSavedPath).writeAsBytesSync(
      img.encodeJpg(thumbnail, quality: 90)); // 품질은 필요에 따라 조절 가능

  return thumbSavedPath;
}

Future<List<DateTime?>> getDateTimeOriginals(List<File> imageFiles) async {
  final results = await Future.wait(imageFiles.map(getDateTimeOriginal));
  return results;
}

Future<DateTime?> getDateTimeOriginal(File imageFile) async {
  final exifData = await readExifFromBytes(await imageFile.readAsBytes());
  String? dateTimeOriginal = exifData['EXIF DateTimeOriginal']?.toString();
  if (dateTimeOriginal == null) {
    return null;
  } else {
    final splits = dateTimeOriginal.split(' ');
    String isoDateTime = "${splits[0].replaceAll(':', '-')}T${splits[1]}";
    try {
      return DateTime.parse(isoDateTime);
    } catch (e) {
      return null;
    }
  }
}
