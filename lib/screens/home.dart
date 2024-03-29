import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/image_service.dart';
import '../models/image.dart';
import '../controllers/local_images_controller.dart';
import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:in_app_review/in_app_review.dart';

class Home extends GetView<LocalImagesController> {
  Home({super.key});

  final ScrollController _scrollController = ScrollController();
  final InAppReview inAppReview = InAppReview.instance;
  

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
              tooltip: '카메라',
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
              tooltip: '업로드',
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
              tooltip: '검색',
              icon: const Icon(CupertinoIcons.search,
                  color: Colors.black54, size: 30),
              onPressed: () {
                Get.toNamed('/search');
              },
            )
          ]),
          backgroundColor: Colors.white,
        ),
        floatingActionButton: Semantics(
          label: '도움말 보기',
          button: true, 
          child: Container(
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
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // 블러 효과 적용
                child: Container(
                  color: Colors.white.withOpacity(0.7), // 반투명한 흰색 배경
                  width: 56, // FAB 기본 크기와 동일
                  height: 56,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        // inAppReview.openStoreListing(appStoreId: '6478280385');
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
        ),
        body: Obx(() {
          if (controller.images == null || controller.images!.isEmpty) {
            return const Center(child: Text('소리앨범에 사진을 추가해 보세요!'));
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
                  return Semantics(
                    explicitChildNodes: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Container(
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Text(monthString,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                          ),
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
                                final semanticLabel = '${DateFormat('d일 a h시 m분', 'ko_KR').format(image.createdAt)} ${image.caption}';
                                if (index == 0) {
                                  String dateString =
                                      "${int.parse(dateGroups.keys.elementAt(i).split('-')[2])}일";
                                  return Semantics(
                                    label: semanticLabel,
                                    explicitChildNodes: true,
                                    excludeSemantics: true,
                                    button: true,
                                    child: GestureDetector(
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
                                              File(image.getPath(thumbnail: true)),
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
                                    ),
                                  );
                                } else {
                                  return Semantics(
                                    label: semanticLabel,
                                    explicitChildNodes: true,
                                    excludeSemantics: true,
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.setCurrentIndex(image.countId!);
                                        Get.toNamed('/image_detail');
                                      },
                                      child: Hero(
                                        tag: 'image_${image.countId}',
                                        child: Image.file(
                                            File(image.getPath(thumbnail: true)),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                }
                              }),
                            ),
                          )
                      ],
                    ),
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
        padding: const EdgeInsets.all(24),
        color: CupertinoColors.white,
        alignment: Alignment.topLeft,
        height: 700,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      child: const Text('닫기',
                          style: TextStyle(
                              inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      child: const Text('리뷰 남기기',
                          style: TextStyle(
                              inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                      onTap: () {
                        inAppReview.openStoreListing(appStoreId: '6478280385');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Semantics(
                container: true,
                child: const Row(children: [
                  Text('소리앨범', style: TextStyle(inherit: false, color: Color.fromRGBO(162, 189, 242, 1), fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(', 이렇게 사용해 보세요!', style: TextStyle(inherit: false, color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                ]),
              ),
              const SizedBox(height: 24),
              const Text('1. 사진 추가', style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text(
                  "앱 최상단 왼쪽부터 카메라, 업로드 버튼을 눌러 사진을 추가해 보세요. 자동으로 사진에 대한 짧은 설명인 '캡션'이 생성됩니다.",
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 18),
              const Text('2. 자세한 설명 받기', style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text(
                  "사진의 상세페이지로 들어가 '자세한 설명 보기' 버튼을 눌러 보세요. AI가 사진에 대한 꼼꼼한 설명과, 사진 속 글자를 인식해 알려줄 거예요. 자세한 설명은 하루에 10회만 생성할 수 있어요.",
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 18),
              const Text('3. 사진 검색', style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text(
                  '앱 최상단 오른쪽 검색 버튼을 눌러 추가한 사진을 검색해 보세요. 찾고 싶은 사진과 관련한 짧은 키워드 또는 사진에 대한 간단한 묘사를 통해 검색하실 수 있습니다.',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 10),
              const Text(
                  '키워드 탭은 검색한 키워드가 포함된 사진들이, 유사도 탭은 검색한 내용과 비슷한 순서로 정렬된 사진들이 노출됩니다.',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 18),
              const Text('4. 사진 공유', style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text(
                  '사진의 상세페이지로 들어가 오른쪽 상단 공유하기 버튼을 눌러보세요. 사진과 캡션을 다른 사람에게 공유할 수 있습니다.',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 10),
              const Text(
                  '앱을 삭제하실 경우, 추가한 사진과 관련한 데이터도 함께 삭제되니 이용에 유의해 주세요.',
                  style: TextStyle(
                      inherit: false, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                child: GestureDetector(
                  child: const Text('확인',
                      style: TextStyle(
                          inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
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
