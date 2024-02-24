import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/local_images_controller.dart';
import '../controllers/search_image_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ImageDetail extends StatelessWidget {
  const ImageDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final controller;
    if (arguments == 'search') {
      controller = Get.find<SearchImagesController>();
    } else {
      controller = Get.find<LocalImagesController>();
    }

    return Obx(() => Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: SizedBox(
              width: 200,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일', 'ko_KR').format(
                          controller.images![controller.index].createdAt),
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                        DateFormat('a h시 m분', 'ko_KR').format(
                            controller.images![controller.index].createdAt),
                        style: TextStyle(fontSize: 14)),
                  ]),
            )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: Expanded(
                child: PageView.builder(
                  itemCount: controller.images!.length,
                  controller: PageController(
                      viewportFraction: 1, initialPage: controller.index),
                  onPageChanged: controller.setCurrentIndex,
                  itemBuilder: (context, index) {
                    final image = controller.images![index];
                    return Hero(
                        tag: arguments == 'search'
                            ? 'search_image_$index'
                            : 'image_$index',
                        child: Image.file(File(image.assetPath),
                            fit: BoxFit.contain));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child:
                    Text(controller.images![controller.index].caption ?? '')),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Row(
                children: List.generate(
                    controller.images![controller.index].generalTags?.length ??
                        0,
                    (index) => Text(controller
                        .images![controller.index].generalTags![index])),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Row(
                children: List.generate(
                    controller.images![controller.index].alertTags?.length ?? 0,
                    (index) => Text(controller
                        .images![controller.index].generalTags![index])),
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child:
                    Text(controller.images![controller.index].userMemo ?? '')),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Text(
                    controller.images![controller.index].description ?? '')),
          ],
        )));
  }
}
