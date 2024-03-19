import 'package:broady_lite/helpers/utils.dart';

class _Image {
  int? id;
  int? countId;

  String? caption;
  String? description;
  String? ocr;
  String? userMemo = 'sample user memo';

  List<String>? generalTags;
  List<String>? alertTags;

  List<double>? vector;

  DateTime storedAt = DateTime.now().localTime;
  DateTime createdAt = DateTime.now().localTime;

  _Image();
}

class LocalImage extends _Image {
  final String assetPath;
  String? thumbAssetPath;
  String? imageUrl;
  String? firestoreId;

  LocalImage(this.assetPath);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetPath': assetPath,
      'thumbAssetPath': thumbAssetPath,
      'imageUrl': imageUrl,
      'firestoreId': firestoreId,
      'caption': caption,
      'description': description,
      'ocr': ocr,
      'userMemo': userMemo,
      'generalTags': generalTags?.join(','),
      'alertTags': alertTags?.join(','),
      'vector': vector?.join(','), // List<double>를 문자열로 변환
      'storedAt': storedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static LocalImage fromMap(Map<String, dynamic> map) {
    final assetPath = map['assetPath'];
    final localImage = LocalImage(assetPath);

    localImage.id = map['id'];
    localImage.thumbAssetPath = map['thumbAssetPath'];
    localImage.imageUrl = map['imageUrl'];
    localImage.firestoreId = map['firestoreId'];
    localImage.caption = map['caption'];
    localImage.description = map['description'];
    localImage.ocr = map['ocr'];
    localImage.userMemo = map['userMemo'];
    localImage.generalTags = map['generalTags']?.split(',');
    localImage.alertTags = map['alertTags']?.split(',');
    localImage.vector = map['vector']
        ?.split(',')
        .map((e) => double.tryParse(e))
        .toList()
        .cast<double>(); // 문자열을 List<double>로 변환
    localImage.storedAt = DateTime.parse(map['storedAt']);
    localImage.createdAt = DateTime.parse(map['createdAt']);

    return localImage;
  }
}
