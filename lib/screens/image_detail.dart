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
      appBar: AppBar(title: Text(controller.images![controller.index].caption ?? '빈 제목')),
      body: Obx(() => 
        Center(
          child: Container(
            child: Column(
              children: [
                PageView.builder(itemBuilder: (context, index) => Image.file(File(controller.images![controller.index].assetPath)))
              ],
            )
          )
        )
      )
    );
  }
}
