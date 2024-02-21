import 'package:photo_manager/photo_manager.dart';

class Album{
  String? id;
  String? name;
  List<AssetEntity>? images;

  Album({required this.id, required this.name, required this.images});

  factory Album.fromGallery(
      String id, String name, List<AssetEntity> images) {
    return Album(id: id, name: name, images: images);
  }
}