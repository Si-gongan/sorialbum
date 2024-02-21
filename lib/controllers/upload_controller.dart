import 'package:photo_manager/photo_manager.dart';
import 'package:get/get.dart';

import '../models/album.dart';

class UploadController extends GetxController {
  //앨범을 담는 Rx변수
  final Rx<List<Album>> _albums = Rx<List<Album>>([]);

  final Rxn<AssetEntity> _selectedImage = Rxn<AssetEntity>();
  final RxInt _index = 0.obs;

  List<Album> get albums => _albums.value;

  AssetEntity? get selectedImage => _selectedImage.value;
  int get index => _index.value;

  @override
  void onReady() {
    super.onReady();
    // 권한 확인
    _checkPermission();
  }

  void _checkPermission() {
    PhotoManager.requestPermissionExtend().then((ps) {
      if (ps.isAuth) {
      	//권한이 승인되었으면 getAlbum 실행
        getAlbums();
      } else {
      	//권한이 없으면 설정을 열음.
        PhotoManager.openSetting();
      }
    });
  }

  void select(AssetEntity e) {
    _selectedImage(e);
    _selectedImage.refresh();
  }

  void changeIndex(int value) {
    _index(value);
  }

  Future<void> getAlbums() async {
    await PhotoManager.getAssetPathList(type: RequestType.image).then((paths) {
      for (AssetPathEntity asset in paths) {
        asset.getAssetListRange(start: 0, end: 10000).then((images) {
          if (images.isNotEmpty) {
            final album = Album.fromGallery(asset.id, asset.name, images);
            _albums.value.add(album);
            _albums.refresh();
          }
        });
      }
    });
  }

  

}