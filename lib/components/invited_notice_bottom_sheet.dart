import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/firestore_helper.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

class InvitedNoticeBottomSheet extends StatefulWidget {
  const InvitedNoticeBottomSheet({super.key});

  @override
  State<InvitedNoticeBottomSheet> createState() => _InvitedNoticeBottomSheetState();
}

class _InvitedNoticeBottomSheetState extends State<InvitedNoticeBottomSheet> {
  final TextEditingController controller = TextEditingController();
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
                const SizedBox(height: 10),
                Semantics(
                  container: true,
                  child: const Row(children: [
                    Text('친구 초대 이벤트', style: TextStyle(inherit: false, color: Color.fromRGBO(162, 189, 242, 1), fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(' 안내', style: TextStyle(inherit: false, color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                  ]),
                ),
                const SizedBox(height: 24),
                const Text(
                    "안녕하세요, 소리앨범입니다.\n친구로부터 소리앨범 초대를 받았나요?",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "초대한 친구의 초대코드를 입력해주시면 추첨을 통해 기프티콘과 점자앨범을 드려요!",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
  
                const SizedBox(height: 24),
                const Text('초대코드 입력하기', style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height:10),
                CupertinoTextField(
                  controller: controller,
                  placeholder: '초대코드를 입력해주세요',
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
                          if (controller.text.trim().isEmpty) {
                            showCupertinoDialog(
                              context: context,
                              builder: 
                              (context) => CupertinoAlertDialog(
                                title: const Text('초대코드 미입력'),
                                content: const Text('초대코드를 입력해주세요.'),
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
                          final myCode = await FirestoreHelper.getInvitationCode();
                          if (controller.text.trim() == myCode) {
                            showCupertinoDialog(
                              context: context,
                              builder: 
                              (context) => CupertinoAlertDialog(
                                title: const Text('알림'),
                                content: const Text('본인의 초대코드는 사용할 수 없습니다.'),
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
                          final isSuccess = await FirestoreHelper.addInvitedUser(controller.text.trim());
                          if (isSuccess) {
                            controller.clear();
                            showCupertinoDialog(
                              context: context,
                              builder: 
                              (context) => CupertinoAlertDialog(
                                title: const Text('제출 완료'),
                                content: const Text('초대코드 입력이 완료되었습니다. 추첨을 기대해주세요!'),
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
                          } else {
                            showCupertinoDialog(
                              context: context,
                              builder: 
                              (context) => CupertinoAlertDialog(
                                title: const Text('알림'),
                                content: const Text('유효하지 않은 초대코드입니다.'),
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
                          }
                        },
                      ),
                    ),
                ],),
                const SizedBox(height: 24),
                const Text('혹은, 내 초대코드를 공유하여 친구를 초대해보세요!', style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        final myCode = await FirestoreHelper.getInvitationCode();
                        Clipboard.setData(ClipboardData(text: myCode));
                        Get.snackbar(
                          '복사 완료',
                          '초대코드가 클립보드에 복사되었습니다.',
                          backgroundColor: Colors.grey[800], // 배경색 설정
                          colorText: Colors.white, // 텍스트 색상 설정
                          snackPosition: SnackPosition.BOTTOM, // 화면 하단에 위치
                          margin: const EdgeInsets.all(0), // 마진 제거
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 좌우 패딩 조정
                          duration: const Duration(seconds: 2), // 지속 시간 설정
                          snackStyle: SnackStyle.GROUNDED,
                        );
                        // semantic announcement
                        SemanticsService.announce('초대코드가 클립보드에 복사되었습니다.', ui.TextDirection.ltr);
                      },
                      child: const Text('내 초대코드 복사하기', style: TextStyle(
                        color: Color.fromRGBO(162, 189, 242, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ))),
                    InkWell(
                      onTap:() async {
                        final myCode = await FirestoreHelper.getInvitationCode();
                        Share.share(myCode);
                      },
                      child: const Text('내 초대코드 공유하기', style: TextStyle(
                        color: Color.fromRGBO(162, 189, 242, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ))),
                ],),
                const SizedBox(height: 24),
                const Text('* 참여 횟수에는 제한 없으며, 여러명에게 공유할수록 당첨될 확률이 높아져요.', style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const Text('* 이 글은 홈 화면 우측 하단 도움말 버튼을 눌러 다시 확인할 수 있습니다.', style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                ],)
              ],
            ),
          )),
    );
  }
}