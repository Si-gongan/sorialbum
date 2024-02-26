import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/image_service.dart';
import '../models/image.dart';
import '../controllers/local_images_controller.dart';
import 'dart:io';
import 'dart:ui';

class Home extends GetView<LocalImagesController> {
  Home({super.key});

  final imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.camera_fill,
                color: Colors.black54,
                size: 30,
              ),
              onPressed: () async {
                final image = await imageService.takePicture();
                if (image != null) {
                  await imageService.saveImagesAndMetadata([image]);
                } else {
                  // when canceled...
                }
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.photo,
                  color: Colors.black54, size: 30),
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
              icon: const Icon(CupertinoIcons.search,
                  color: Colors.black54, size: 30),
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
            var groupedImages =
                controller.groupImagesByMonthAndDate(controller.images!);
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: groupedImages.keys.length,
                itemBuilder: (context, index) {
                  String month = groupedImages.keys.elementAt(index);
                  String monthString =
                      "${month.split('-')[0]}년 ${int.parse(month.split('-')[1])}월";
                  Map<String, List<LocalImage>> dateGroups =
                      groupedImages[month]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.05),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Text(monthString,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                      ),
                      for (int i = 0; i < dateGroups.keys.length; i++)
                        Container(
                          margin: EdgeInsets.only(bottom: i < dateGroups.keys.length - 1 ? 2 : 0),
                          child: GridView.count(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            children: List.generate(dateGroups[dateGroups.keys.elementAt(i)]!.length, (index) {
                              final image = dateGroups[dateGroups.keys.elementAt(i)]![index];
                              if (index == 0) {
                                String dateString =
                                    "${int.parse(dateGroups.keys.elementAt(i).split('-')[2])}일";
                                return GestureDetector(
                                  onTap: () {
                                    controller.setCurrentIndex(image.countId!);
                                    Get.toNamed('/image_detail');
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Hero(
                                        tag: 'image_${image.countId}',
                                        child: Image.file(
                                          File(image.thumbAssetPath ??
                                              image.assetPath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                          top: 5,
                                          left: 5,
                                          child:
                                              _dateBlurredContainer(dateString)),
                                    ],
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    controller.setCurrentIndex(image.countId!);
                                    Get.toNamed('/image_detail');
                                  },
                                  child: Hero(
                                    tag: 'image_${image.countId}',
                                    child: Image.file(
                                        File(image.thumbAssetPath ??
                                            image.assetPath),
                                        fit: BoxFit.cover),
                                  ),
                                );
                              }
                            }),
                          ),
                        )
                    ],
                  );
                });
          }
        }));
  }

  Widget _dateBlurredContainer(String text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.15))
      ]),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            width: 40, // 흐림 효과를 적용할 컨테이너의 너비
            height: 24, // 흐림 효과를 적용할 컨테이너의 높이
            decoration: BoxDecoration(
                color: Colors.grey.shade200.withOpacity(0.6), // 반투명 배경 색상
                borderRadius: BorderRadius.circular(20)), // 경계선 둥글게 처리),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
