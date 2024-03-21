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
import 'package:firebase_storage/firebase_storage.dart';
import 'firestore_helper.dart';
import '../app_config.dart';

final ImagePicker _picker = ImagePicker();
final dbHelper = DatabaseHelper();
final storageRef = FirebaseStorage.instance.ref();


class ImageService {
  static final LocalImagesController localImageController = Get.find<LocalImagesController>();
  static final SearchImagesController searchImageController = _findOrCreateSearchImageController();

  static SearchImagesController _findOrCreateSearchImageController() {
    try {
      // Get.find()를 시도하여 이미 등록된 인스턴스가 있는지 확인
      return Get.find<SearchImagesController>();
    } catch (e) {
      // 등록된 인스턴스가 없을 경우, 새로운 인스턴스를 생성하고 주입
      return Get.put(SearchImagesController());
    }
  }

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

    
    final List<File> thumbImageFiles =
      await Future.wait(localImageFilePaths.map((path_) async {
      final File imageFile = File(path.join(AppConfig.appDocumentsDirectory!, path_['thumbSavedPath']!));
      return imageFile;
    }));

    // second stage: get cloud urls
    List<String> imageUrls = await uploadImagesToFirebase(thumbImageFiles);

    // third stage: get tags, embeddings
    List<List<String>> tags =
        await ApiService.fetchAzureTags(imageUrls, maxNumber: 5, caption: false, lang: "ko");

    List<List<double>> embeddings =
        await ApiService.fetchImageEmbeddings(imageUrls);

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].imageUrl = imageUrls[i];
      localImages[i].generalTags = tags[i];
      localImages[i].vector = embeddings[i];
      // if we using azure caption
      // localImages[i].caption = tags[localImages.length][i];
    }

    // second UI update
    await dbHelper.updateImagesByMaps(localImages
        .map((e) => {
              for (var key in [
                'assetPath',
                'imageUrl',
                'generalTags',
                'vector',
              ])
                key: e.toMap()[key]
            })
        .toList());
    // localImageController.updateImages(localImages);
    // if (searchImageController.initialized) {
    //   searchImageController.updateImages(localImages);
    // }

    // 4th stage: get captions
    List<String> captions = await ApiService.fetchGPTCaptions(thumbImageFiles);

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

    // 5th stage: firestore
    final firestoreIds = await FirestoreHelper.storeImages(localImages.map((e) => e.toMap()).toList());

    for (int i = 0; i < localImages.length; i++) {
      localImages[i].firestoreId = firestoreIds[i];
    }
    await dbHelper.updateImagesByMaps(localImages
        .map((e) => {
              for (var key in [
                'assetPath',
                'firestoreId'
              ])
                key: e.toMap()[key]
            })
        .toList());
  }

  static Future<void> getDescription(LocalImage image) async {
    image.description = '설명을 생성중이에요...';
    localImageController.updateImage(image);
    if (searchImageController.initialized) {
      searchImageController.updateImage(image);
    }

    File imageFile = File(image.getPath());
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

    File imageFile = File(image.getPath());
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

Future<List<String>> uploadImagesToFirebase(List<File> images) async {
  // FirebaseStorage 인스턴스 생성
  final storageRef = FirebaseStorage.instance.ref();

  // 업로드할 파일 각각에 대해 비동기 업로드 작업 생성R
  List<Future<TaskSnapshot>> uploadTasks = images.map((image) {
    // 저장할 경로와 파일 이름 지정 (예: 'images/imageName.png')
    String filePath = 'images/${DateTime.now().toLocal().millisecondsSinceEpoch}-${path.basename(image.path)}';
    Reference fileRef = storageRef.child(filePath);

    // 파일 업로드 시작
    return fileRef.putFile(image);
  }).toList();

  // 모든 업로드 작업이 완료될 때까지 기다림
  List<TaskSnapshot> results = await Future.wait(uploadTasks);

  // 업로드 결과 처리 (예: URL 가져오기)
  List<String> imageUrls = [];
  for (TaskSnapshot result in results) {
    String imageUrl = await result.ref.getDownloadURL();
    imageUrls.add(imageUrl);
  }

  // 업로드된 이미지 URL 리스트 사용
  return imageUrls;
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
  final thumbFileName= await createThumbnail(imageFile.path, directory.path);

  return {'savedPath': fileName, 'thumbSavedPath': thumbFileName};
}

Future<String> createThumbnail(String filePath, String saveDir) async {
  final fileName = path.basenameWithoutExtension(filePath);
  final thumbFileName = 'thumb_$fileName.jpg';
  final thumbSavedPath = path.join(saveDir, thumbFileName);

  // 이미지 파일 읽기
  final imageBytes = File(filePath).readAsBytesSync();
  img.Image? image = img.decodeImage(imageBytes);

  // 섬네일 이미지 생성
  img.Image thumbnail = img.copyResize(image!, width: 250);

  // JPEG 형식으로 섬네일 이미지 저장
  File(thumbSavedPath).writeAsBytesSync(
      img.encodeJpg(thumbnail, quality: 90)); // 품질은 필요에 따라 조절 가능

  return thumbFileName;
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
