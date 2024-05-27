import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/firestore_helper.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

class InvitingNoticeBottomSheet extends StatefulWidget {
  const InvitingNoticeBottomSheet({super.key});

  @override
  State<InvitingNoticeBottomSheet> createState() => _InvitingNoticeBottomSheetState();
}

class _InvitingNoticeBottomSheetState extends State<InvitingNoticeBottomSheet> {
  final TextEditingController phoneController = TextEditingController();
  final focusNode = FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          padding: const EdgeInsets.all(24),
          color: CupertinoColors.white,
          alignment: Alignment.topLeft,
          height: 500,
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
                    "안녕하세요, 소리앨범입니다.\n소리앨범을 사용해 주셔서 감사합니다.\n고마움에 보답해 드리기 위해 친구 초대 이벤트를 준비했어요!",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "아직 소리앨범을 써보지 않은 친구가 내 초대코드를 입력하면\n추첨을 통해 기프티콘과 점자앨범을 드려요!",
                    style: TextStyle(
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
                const Text('* 이 글은 홈 화면 우측 하단 도움말 버튼을 눌러 다시 확인할 수 있어요.', style: TextStyle(
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