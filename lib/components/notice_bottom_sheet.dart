import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import '../helpers/firestore_helper.dart';

class NoticeBottomSheet extends StatefulWidget {
  const NoticeBottomSheet({super.key});

  @override
  State<NoticeBottomSheet> createState() => _NoticeBottomSheetState();
}

class _NoticeBottomSheetState extends State<NoticeBottomSheet> {
  final InAppReview inAppReview = InAppReview.instance;
  final TextEditingController phoneController = TextEditingController();
  final focusNode = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          padding: const EdgeInsets.all(24),
          color: CupertinoColors.white,
          alignment: Alignment.topLeft,
          height: 600,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Semantics(
                //       button: true,
                //       child: GestureDetector(
                //         child: const Text('닫기',
                //             style: TextStyle(
                //                 inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                //         onTap: () {
                //           Get.back();
                //         },
                //       ),
                //     ),
                //     Semantics(
                //       button: true,
                //       child: GestureDetector(
                //         child: const Text('리뷰 남기기',
                //             style: TextStyle(
                //                 inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                //         onTap: () {
                //           inAppReview.openStoreListing(appStoreId: '6478280385');
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                Semantics(
                  container: true,
                  child: const Row(children: [
                    Text('인터뷰이 모집', style: TextStyle(inherit: false, color: Color.fromRGBO(162, 189, 242, 1), fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(' 안내', style: TextStyle(inherit: false, color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                  ]),
                ),
                const SizedBox(height: 24),
                const Text(
                    "안녕하세요, 소리앨범입니다.\n소리앨범을 사랑해주셔서 정말 감사드립니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "더 나은 서비스를 제공하기 위해,\n서비스를 잘 이용해 주시고 계시는 분들을 대상으로 인터뷰를 진행하고자 합니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "인터뷰는 소리앨범을 어떻게 사용하시는 지에 대한 질문으로 진행될 예정이며, 약 60분 정도 소요됩니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "직접 만나서 진행하는 것을 생각하고 있으나 조정이 가능합니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "참여해 주시는 분들께는 사례금 1만원과, 인터뷰 당일 교통비, 카페비를 지급해 드리고자 하니 많은 관심 부탁드립니다!",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 24),
                const Text('인터뷰 관련 연락드릴 전화번호를 적어 주세요!', style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height:10),
                CupertinoTextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  placeholder: '전화번호를 입력해주세요',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    // border: Border.all(width:1, color: Colors.grey),
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                  ),
                  focusNode: focusNode,
                  onTapOutside: (p){
                    focusNode.unfocus();
                  },
                  onSubmitted: (value){
                    focusNode.unfocus();
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        child: const Text('제출하기',
                            style: TextStyle(
                                inherit: false, color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
                        onTap: () async {
                          if (phoneController.text.trim().isEmpty) {
                            showCupertinoDialog(
                              context: context,
                              builder: 
                              (context) => CupertinoAlertDialog(
                                title: const Text('전화번호 미입력'),
                                content: const Text('전화번호를 입력해주세요.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('확인'),
                                    onPressed: (){
                                      Get.back();
                                    }
                                  )
                                ],
                              )
                            );
                            return;
                          }
                          // upload at firebase
                          await FirestoreHelper.saveIntervieweeContact(phoneController.text);
                          Get.back();
                          showCupertinoDialog(
                            context: context,
                            builder: 
                            (context) => CupertinoAlertDialog(
                              title: const Text('제출 완료'),
                              content: const Text('인터뷰 참여 신청이 완료되었습니다.\n소중한 시간 내주셔서 감사합니다.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('확인'),
                                  onPressed: (){
                                    Get.back();
                                  }
                                )
                              ],
                            )
                          );
                        },
                      ),
                    ),
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
                ],)
                
              ],
            ),
          )),
    );
  }
}