import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../controllers/upload_controller.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class Album extends GetView<UploadController> {
  const Album({super.key});

	@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.albums[controller.index].name.toString())),
      // Obx를 통해서 화면을 갱신함.
      body: Obx(
        () => GridView.count(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 5,
          children: List.generate(
            controller.albums[controller.index].images!.length,
            (index) => AssetEntityImage(controller.albums[controller.index].images![index], fit: BoxFit.cover, isOriginal: false, thumbnailSize: const ThumbnailSize.square(100),)))
            ));
  }
}