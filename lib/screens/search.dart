import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/search_image_controller.dart';
import 'dart:io';

class Search extends GetView<SearchImagesController> {
  Search({super.key});

  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black54,
            title: Container(
              // decoration: BoxDecoration(border: Border.all(width:1)),
              child: CupertinoTextField(
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  // border: Border.all(width:1, color: Colors.grey),
                  color: Color.fromRGBO(0, 0, 0, 0.07),
                ),
                focusNode: focusNode,
                controller: textEditingController,
                onTap: () {},
                onTapOutside: (p) {
                  focusNode.unfocus();
                  // FocusScope.of(context).unfocus();
                },
                onEditingComplete: () {},
                onChanged: (value) {
                  if (value.isEmpty) {
                    focusNode.unfocus();
                    controller.setResult(false);
                  }
                },
                onSubmitted: (value) {
                  controller.queryImages(value);
                  focusNode.unfocus();
                },
                placeholder: '원하는 사진을 검색해보세요',
                clearButtonMode: OverlayVisibilityMode.editing,
                cursorColor: Colors.black54,
                autofocus: true,
              ),
            ),
            actions: []),
        body: Obx(() {
          if (!controller.result) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('최근 검색',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      InkWell(
                        onTap: () {
                          controller.clearSearchHistory();
                        },
                        child: Text('전체 삭제',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.queries?.length ?? 0,
                      itemBuilder: (context, index) {
                        String query =
                            controller.queries!.reversed.toList()[index];
                        return InkWell(
                          onTap: () {
                            focusNode.unfocus();
                            textEditingController.text = query;
                            controller.queryImages(query);
                          },
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 20),
                              child:
                                  Text(query, style: TextStyle(fontSize: 14))),
                        );
                      }),
                )
              ],
            );
          } else {
            if (controller.images == null || controller.images!.isEmpty) {
              return const Center(child: Text('검색 결과가 없습니다'));
            } else {
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: controller.images!.length,
                itemBuilder: (context, index) {
                  final image = controller.images![index];
                  return GestureDetector(
                      onTap: () {
                        controller.setCurrentIndex(index);
                        Get.toNamed('/image_detail', arguments: 'search');
                      },
                      child: Hero(
                          tag: 'search_image_$index',
                          child: Image.file(
                              File(image.thumbAssetPath ?? image.assetPath),
                              fit: BoxFit.cover)));
                },
              );
            }
          }
        }));
  }
}
