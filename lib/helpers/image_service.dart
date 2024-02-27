import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_helper.dart';
import '../models/image.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../controllers/local_images_controller.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:broady_lite/helpers/utils.dart';
import 'api_service.dart';

final ImagePicker _picker = ImagePicker();
final ApiService _apiService = ApiService();

final dbHelper = DatabaseHelper();
final controller = Get.find<LocalImagesController>();

class ImageService {
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

  Future<void> saveImagesAndMetadata(List<XFile> pickedFiles) async {
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

    // UI update
    controller.addImages(localImages);
    //  Get.snackbar(
    //   '이미지 불러오기 완료', // 제목
    //   '총 ${localImages.length}개의 이미지를 성공적으로 불러왔습니다.', // 메시지
    //   backgroundColor: Colors.grey[800], // 배경색 설정
    //   colorText: Colors.white, // 텍스트 색상 설정
    //   snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
    //   margin: EdgeInsets.all(0), // 마진 제거
    //   padding: EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
    //   duration: Duration(seconds: 4), // 지속 시간 설정
    //   snackStyle: SnackStyle.GROUNDED,
    // );

    // second stage: get cloud urls
    List<String> imageUrls = await _apiService.fetchImageUrls(imageFiles);

    // third stage: get tags, embeddings
    List<List<String>> tags =
        await _apiService.fetchAzureTags(imageUrls, maxNumber: 5, lang: "ko");

    List<List<double>> embeddings =
        await _apiService.fetchImageEmbeddings(imageUrls);

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].imageUrl = imageUrls[i];
      localImages[i].generalTags = tags[i];
      localImages[i].vector = embeddings[i];
    }

    controller.updateImages(localImages);

    // 4th stage: get captions
    List<String> captions = await _apiService.fetchGPTCaptions(imageFiles);

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].caption = captions[i];
    }

    await dbHelper.insertImages(localImages);
    controller.updateImages(localImages);
    Get.snackbar(
      '이미지 캡션 생성 완료', // 제목
      '총 ${localImages.length}개의 이미지 캡션 생성이 완료되었습니다.', // 메시지
      backgroundColor: Colors.grey[800], // 배경색 설정
      colorText: Colors.white, // 텍스트 색상 설정
      snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
      margin: EdgeInsets.all(0), // 마진 제거
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
      duration: Duration(seconds: 4), // 지속 시간 설정
      snackStyle: SnackStyle.GROUNDED,
    );
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
