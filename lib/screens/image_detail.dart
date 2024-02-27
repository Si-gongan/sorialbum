import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/local_images_controller.dart';
import '../controllers/search_image_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

enum Annotation { description, ocr }

class ImageDetail extends StatefulWidget {
  const ImageDetail({super.key});

  @override
  State<ImageDetail> createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  Annotation _selectedSegment = Annotation.description;

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
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                        DateFormat('a h시 m분', 'ko_KR').format(
                            controller.images![controller.index].createdAt),
                        style: const TextStyle(fontSize: 14)),
                  ]),
            ),
            actions: [
              // IconButton(icon: Icon(CupertinoIcons.ellipsis_circle, size: 30), onPressed: (){
              //   Get.bottomSheet(Container(
              //     color: Colors.white,
              //     height: 200,
              //     child: Center(
              //       child: Text('bottom sheet')
              //     ),
              //   ),
              //   barrierColor: Colors.black.withOpacity(0.4), // 배경색 설정
              //   isDismissible: true,);
              // }),
              IconButton(
                  icon: const Icon(CupertinoIcons.ellipsis_circle, size: 30),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        // title: Text('title'),
                        // message: Text('Here is your action sheet'),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              Navigator.pop(context);
                              await Share.shareXFiles([
                                XFile(controller
                                    .images![controller.index].assetPath)
                              ],
                                  text: controller
                                      .images![controller.index].caption);
                            },
                            child: const Text('공유하기'),
                          ),
                          CupertinoActionSheetAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                              showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                        title: const Text('알림'),
                                        content:
                                            const Text('사진을 갤러리에서 삭제하시겠습니까?'),
                                        actions: <Widget>[
                                          // 다이얼로그 닫기 버튼
                                          CupertinoDialogAction(
                                            child: const Text('취소'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          // 다른 액션을 수행하는 버튼
                                          CupertinoDialogAction(
                                            isDestructiveAction: true,
                                            child: const Text('삭제'),
                                            onPressed: () {
                                              controller.removeImage(controller
                                                  .images![controller.index]);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ));
                            },
                            child: const Text('삭제하기'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('취소'),
                        ),
                      ),
                    );
                  })
            ]),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
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
            const SizedBox(height: 20),
            // caption
            Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: controller.images![controller.index].caption != null
                    ? Text(controller.images![controller.index].caption)
                    : Row(children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 16,
                          width: 16,
                          child: const CupertinoActivityIndicator(
                            radius: 8,
                          ),
                        ),
                        const Text('캡션을 생성중이에요...')
                      ])),
            // genearl tags
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Wrap(spacing: 8, runSpacing: 6, children: [
                ...List.generate(
                    controller.images![controller.index].generalTags?.length ??
                        0,
                    (index) => _tag(
                        controller
                            .images![controller.index].generalTags![index],
                        type: 'general')),
                ...List.generate(
                    controller.images![controller.index].alertTags?.length ?? 0,
                    (index) => _tag(
                        controller.images![controller.index].alertTags![index],
                        type: 'alert'))
              ]),
            ),
            const SizedBox(height: 6),
            // user memo
            Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child:
                    Text(controller.images![controller.index].userMemo ?? '')),
            // annotations
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              width: double.infinity,
              alignment: Alignment.center,
              child: CupertinoSlidingSegmentedControl(
                groupValue: _selectedSegment,
                onValueChanged: ((Annotation? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSegment = value;
                    });
                  }
                }),
                children: const <Annotation, Widget>{
                  Annotation.description: Text('자세한 설명'),
                  Annotation.ocr: Text('글자 인식'),
                },
              ),
            ),

            Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Text(_selectedSegment == Annotation.description
                    ? controller.images![controller.index].description ?? ''
                    : controller.images![controller.index].ocr ?? '')),
          ],
        )));
  }

  Widget _tag(String text, {String? type}) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
        decoration: BoxDecoration(
            color: type == 'general'
                ? Colors.black.withOpacity(0.06)
                : Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(5)),
        child: type == 'general'
            ? Text(text, style: TextStyle(color: Colors.black))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(text, style: TextStyle(color: Colors.white)),
                ],
              ));
  }
}
