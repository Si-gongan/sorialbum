import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpers/image_service.dart';
import '../controllers/local_images_controller.dart';
import 'dart:io';

class ImageDetail extends GetView<LocalImagesController> {
  ImageDetail({super.key});

  final imageService = ImageService();
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(controller.images![controller.index].createdAt
                .toIso8601String())),
        body: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.center,
                    height: 400,
                    child: Image.file(
                        File(controller.images![controller.index].assetPath),
                        fit: BoxFit.contain)),
                SizedBox(height: 20),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Text(
                        controller.images![controller.index].caption ?? '')),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Row(
                    children: List.generate(
                        controller.images![controller.index].generalTags
                                ?.length ??
                            0,
                        (index) => Text(controller
                            .images![controller.index].generalTags![index])),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Row(
                    children: List.generate(
                        controller
                                .images![controller.index].alertTags?.length ??
                            0,
                        (index) => Text(controller
                            .images![controller.index].generalTags![index])),
                  ),
                ),
                Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Text(
                        controller.images![controller.index].userMemo ?? '')),
                Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Text(
                        controller.images![controller.index].description ?? ''))
                // PageView.builder(
                //     itemCount: controller.images!.length,
                //     itemBuilder: (context, index) => Image.file(
                //         fit: BoxFit.cover,
                //         File(controller.images![controller.index].assetPath)))
              ],
            )));
  }
}
