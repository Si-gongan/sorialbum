class Image {
  int? id;

  String? caption = DateTime.now().toString();
  String? description = 'sample description';
  String? userMemo = 'sample user memo';

  List<String>? generalTags = ['gtag1', 'gtag2', 'gtag3'];
  List<String>? alertTags = ['atag1', 'atag2'];

  List<double>? vector;

  DateTime createdAt = DateTime.now();

  Image();
}

class LocalImage extends Image{
  final String assetPath;
  String? assetEntityId;

  LocalImage(this.assetPath);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetPath': assetPath,
      'caption': caption,
      'description': description,
      'userMemo': userMemo,
      'generalTags': generalTags?.join(','),
      'alertTags': alertTags?.join(','),
      'vector': vector?.join(','), // List<double>를 문자열로 변환
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static LocalImage fromMap(Map<String, dynamic> map) {
    final assetPath = map['assetPath'];
    final localImage = LocalImage(assetPath);

    localImage.id = map['id'];
    localImage.caption = map['caption'];
    localImage.description = map['description'];
    localImage.userMemo = map['userMemo'];
    localImage.generalTags = map['generalTags']?.split(',');
    localImage.alertTags = map['alertTags']?.split(',');
    localImage.vector = map['vector']?.split(',').map((e) => double.tryParse(e) ?? 0.0).toList().cast<double>(); // 문자열을 List<double>로 변환
    localImage.createdAt = DateTime.parse(map['createdAt']);

    return localImage;
  }
}

