import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/image_service.dart';
import '../controllers/local_images_controller.dart';

class Home extends GetView<LocalImagesController> {
  Home({super.key});

  final imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          IconButton(
            icon: Icon(
              CupertinoIcons.camera_fill,
              color: Colors.black54,
              size: 30,
            ),
            onPressed: () async {
              final image = await imageService.takePicture();
              if (image != null) {
                await imageService.saveImageAndMetadata(image);
              } else {
                // when canceled...
              }
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.photo, color: Colors.black54, size: 30),
            onPressed: () async {
              final images = await imageService.pickImagesFromGallery();
              if (images!.isNotEmpty) {
                await imageService.saveImagesAndMetadata(images);
              } else {
                // when canceled...
              }
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.search, color: Colors.black54, size: 30),
            onPressed: () {
              Get.toNamed('/search');
            },
          )
        ]),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        // Obx를 사용하여 컨트롤러의 상태 변화를 감지합니다.
        if (controller.images == null || controller.images!.isEmpty) {
          return const Center(child: Text('갤러리에 사진을 추가해보세요!'));
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: controller.images!.length,
            itemBuilder: (context, index) {
              final image = controller.images![index];
              return GestureDetector(
                onTap: () {
                  controller.setCurrentIndex(index);
                  Get.toNamed('/image_detail');
                },
                child: Hero(tag: 'image_$index', child: Image.asset(image.assetPath, fit: BoxFit.cover))
              );
            },
          );
        }
      }),
      // Center(
      //   child: Column(children: [
      //     Expanded(
      //       child: ListView.builder(
      //           physics: const BouncingScrollPhysics(),
      //           itemCount: 20,
      //           itemBuilder: (context, index) => Column(
      //                 children: [
      //                   Text(index.toString()),
      //                   GridView.count(
      //                       physics: const ClampingScrollPhysics(),
      //                       shrinkWrap: true,
      //                       crossAxisCount: 5,
      //                       children: List.generate(
      //                           8,
      //                           (index2) => Card(
      //                               child: Text(index2.toString()),
      //                               color: Colors.white38)))
      //                 ],
      //               )),
      //     ),
      //     ElevatedButton(
      //         child: Text('to search'),
      //         onPressed: () {
      //           Get.toNamed('/search');
      //         }),
      //     ElevatedButton(
      //         child: Text('to detail'),
      //         onPressed: () {
      //           Get.toNamed('/image_detail');
      //         })
      //   ]),
      // )
    );
  }
}
