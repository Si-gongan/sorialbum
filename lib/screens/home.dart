import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/image_service.dart';
import '../models/image.dart';
import '../controllers/local_images_controller.dart';
import 'dart:io';
import 'dart:ui';

class Home extends GetView<LocalImagesController> {
  Home({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final GetStorage box = GetStorage();
      final isFirstRun = box.read('isFirstRun') ?? true;
      if (isFirstRun) {
        box.write('isFirstRun', false);
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoPopupSurface(child: _onboardingPageView());
          },
        );
      }
    });
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
                final image = await ImageService.takePicture();
                if (image != null) {
                  await ImageService.saveImagesAndMetadata([image]);
                } else {
                  // when canceled...
                }
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.photo,
                  color: Colors.black54, size: 30),
              onPressed: () async {
                final images = await ImageService.pickImagesFromGallery();
                if (images!.isNotEmpty) {
                  await ImageService.saveImagesAndMetadata(images);
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
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28), // FAB의 모서리 둥글기
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 4), // 그림자 위치 조정
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28), // FAB의 모서리 둥글기를 조정합니다.
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 블러 효과 적용
              child: Container(
                color: Colors.white.withOpacity(0.7), // 반투명한 흰색 배경
                width: 56, // FAB 기본 크기와 동일
                height: 56,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoPopupSurface(
                              child: _onboardingPageView());
                        },
                      );
                    }, // 여기에 버튼 클릭 시 수행할 동작을 추가합니다.
                    child: const Center(
                      child: Icon(CupertinoIcons.question, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.images == null || controller.images!.isEmpty) {
            return const Center(child: Text('소리앨범에 사진을 추가해보세요!'));
          } else {
            var groupedImages =
                controller.groupImagesByMonthAndDate(controller.images!);
            return ListView.builder(
                controller: _scrollController,
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
                          margin: EdgeInsets.only(
                              bottom: i < dateGroups.keys.length - 1 ? 2 : 0),
                          child: GridView.count(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            children: List.generate(
                                dateGroups[dateGroups.keys.elementAt(i)]!
                                    .length, (index) {
                              final image = dateGroups[
                                  dateGroups.keys.elementAt(i)]![index];
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
                                          child: _dateBlurredContainer(
                                              dateString)),
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
                color: Colors.grey.shade200.withOpacity(0.75), // 반투명 배경 색상
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

  Widget _onboardingPageView() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: CupertinoColors.white,
        alignment: Alignment.topLeft,
        height: 600,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: const Text('닫기',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              onTap: () {
                Get.back();
              },
            ),
            const SizedBox(height: 14),
            const Text('소리앨범에 오신 것을 환영합니다!',
                style: TextStyle(
                    inherit: false,
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            const Text(
                '1. 상단의 카메라와 갤러리 버튼을 눌러 소리앨범에 사진을 추가해보세요. 앨범에 추가된 사진은 자동으로 짧은 캡션이 생성됩니다.',
                style: TextStyle(
                    inherit: false, color: Colors.black, fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
                '2. 사진의 자세한 정보를 얻고 싶다면 AI를 통해 글자를 인식하고 자세한 설명을 생성해보세요.\n자세한 설명 생성 횟수는 하루 10회로 제한됩니다.',
                style: TextStyle(
                    inherit: false, color: Colors.black, fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
                '3. 원하는 사진을 찾고 싶다면 상단의 검색 버튼을 눌러 찾고 싶은 키워드, 혹은 사진에 대해 간단한 묘사를 입력해보세요.\n검색한 키워드 정보가 포함된 사진들과, 유사도가 높은 순으로 정렬된 사진들을 확인할 수 있습니다.',
                style: TextStyle(
                    inherit: false, color: Colors.black, fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
                '4. 이미지 상세 화면의 우측 상단 공유하기 버튼을 통해 사진과 캡션을 다른사람과 쉽게 공유해보세요.',
                style: TextStyle(
                    inherit: false, color: Colors.black, fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
                '5. 모든 사진은 외부에 업로드되지 않고 앱 데이터 내부에만 저장되며, 앱을 삭제하실 경우 저장된 데이터도 초기화되므로 이용에 유의해주시기 바랍니다.',
                style: TextStyle(
                    inherit: false, color: Colors.black, fontSize: 16)),
            const SizedBox(height: 16),
            GestureDetector(
              child: const Text('확인',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ));
  }

  // TODO : 원하는 월/일 위치로 스크롤하는 함수
  void scrollToTargetDate(String targetMonth, int targetDay) {
    // 이 예제에서는 groupedImages와 같은 데이터 구조를 가정합니다.
    var groupedImages =
        controller.groupImagesByMonthAndDate(controller.images!);
    double position = 0.0; // 스크롤할 위치를 계산하여 저장하는 변수

    // 원하는 위치를 찾기 위한 로직
    // 여기서는 단순화를 위해 각 월/일별 아이템의 높이가 동일하다고 가정합니다.
    // 실제로는 각 아이템의 높이를 계산하여 합산해야 할 수도 있습니다.
    for (String month in groupedImages.keys) {
      if (month == targetMonth) {
        // 월이 일치할 경우, 해당 월의 일별 그룹을 확인
        Map<String, List<LocalImage>> dateGroups = groupedImages[month]!;
        for (String date in dateGroups.keys) {
          if (int.parse(date.split('-')[2]) == targetDay) {
            break; // 일치하는 날짜를 찾으면 반복 종료
          }
          // position += 아이템의 높이; // 실제 아이템의 높이에 따라 조정 필요
        }
        break; // 월이 일치하고 날짜까지 확인했으면 반복 종료
      } else {
        // position += 월 헤더의 높이 + 해당 월의 모든 아이템 높이의 합;
      }
    }

    // 계산된 위치로 스크롤 이동
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
