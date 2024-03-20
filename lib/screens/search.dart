import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/search_image_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
                maxLength: 70,
                prefix: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 9),
                  child: const Icon(CupertinoIcons.search),
                ),
                padding: const EdgeInsets.fromLTRB(0, 9, 12, 9),
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
                    // focusNode.unfocus();
                    controller.setState('initial');
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
          if (controller.state == 'loading') {
            return const Center(child: CupertinoActivityIndicator(radius: 16));
          } else if (controller.state == 'initial') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        header: true,
                        child: const Text('최근 검색',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      Semantics(
                        button: true,
                        child: InkWell(
                          onTap: () {
                            controller.clearSearchHistory();
                          },
                          child: const Text('전체 삭제',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400)),
                        ),
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
                        return Semantics(
                          button: true,
                          child: InkWell(
                            onTap: () {
                              focusNode.unfocus();
                              textEditingController.text = query;
                              controller.queryImages(query);
                            },
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 20),
                                child: Text(query,
                                    style: const TextStyle(fontSize: 14))),
                          ),
                        );
                      }),
                )
              ],
            );
          } else {
            return Column(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: CupertinoSlidingSegmentedControl(
                  groupValue: controller.type,
                  onValueChanged: ((String? value) {
                    if (value != null) {
                      controller.setType(value);
                    }
                  }),
                  children: const <String, Widget>{
                    'filtered': Text('키워드 포함'),
                    'sorted': Text('유사도 순'),
                  },
                ),
              ),
              controller.images == null || controller.images!.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다'))
                  : Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: controller.images!.length,
                        itemBuilder: (context, index) {
                          final image = controller.images![index];
                          final semanticLabel = '${DateFormat('yyyy년 M월 d일 a h시 m분', 'ko_KR').format(image.createdAt)} ${image.caption}';
                          return Semantics(
                            label: semanticLabel,
                            button: true, 
                            explicitChildNodes: true,
                            excludeSemantics: true,
                            child: GestureDetector(
                                onTap: () {
                                  controller.setCurrentIndex(index);
                                  Get.toNamed('/image_detail',
                                      arguments: 'search');
                                },
                                child: Hero(
                                    tag: 'search_image_$index',
                                    child: Image.file(
                                        File(image.getPath(thumbnail: true)),
                                        fit: BoxFit.cover))),
                          );
                        },
                      ),
                    )
            ]);
          }
        }));
  }
}
