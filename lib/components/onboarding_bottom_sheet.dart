import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';

class OnboardingBottomSheet extends StatefulWidget {
  const OnboardingBottomSheet({super.key});

  @override
  State<OnboardingBottomSheet> createState() => _OnboardingBottomSheetState();
}

class _OnboardingBottomSheetState extends State<OnboardingBottomSheet> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {

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
}