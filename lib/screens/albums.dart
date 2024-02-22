import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../controllers/upload_controller.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class Albums extends GetView<UploadController> {
  const Albums({super.key});

	@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Albums')),
      // Obx를 통해서 화면을 갱신함.
      body: Obx(
        () => ListView.builder(
          itemCount: controller.albums.length,
          itemBuilder: ((context, index) => 
          InkWell(
            onTap:() {
              controller.changeIndex(index);
              Get.toNamed('/album');
            },
            child: Container(
              height: 120,
              margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Row(children: [
                Container(width: 120, child: AssetEntityImage(controller.albums[index].images![0], fit: BoxFit.cover, isOriginal: false, thumbnailSize: const ThumbnailSize.square(200))),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SizedBox(height: 10),
                  Text(controller.albums[index].name.toString()),
                  SizedBox(height: 10),
                  Text(controller.albums[index].images!.length.toString()),
                ],)
                
              ],)),
          )),
          )
        )
      );
  }
}