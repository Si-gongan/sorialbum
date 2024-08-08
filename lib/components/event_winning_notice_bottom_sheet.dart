import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class EventWinningNoticeBottomSheet extends StatefulWidget {
  const EventWinningNoticeBottomSheet({super.key});

  @override
  State<EventWinningNoticeBottomSheet> createState() => _EventWinningNoticeBottomSheetState();
}

class _EventWinningNoticeBottomSheetState extends State<EventWinningNoticeBottomSheet> {
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          padding: const EdgeInsets.all(24),
          color: CupertinoColors.white,
          alignment: Alignment.topLeft,
          height: 400,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Semantics(
                  container: true,
                  child: const Row(children: [
                    Text('친구초대 이벤트 당첨', style: TextStyle(inherit: false, color: Color.fromRGBO(162, 189, 242, 1), fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(' 안내', style: TextStyle(inherit: false, color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                  ]),
                ),
                const SizedBox(height: 24),
                const Text(
                    "안녕하세요, 소리앨범을 운영하고 있는 시공간입니다!\n소리앨범 친구 초대 이벤트에 참여해주셔서 감사드립니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "해당 공지는 친구 초대 이벤트 당첨자분들에게만 제공되는 안내입니다. 이벤트 당첨을 축하드립니다!",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                const Text(
                    "이벤트 당첨자분들께 개별적으로 보상을 전달드릴 예정이니, 당첨자분들께서는 아래 시공간 카카오톡 채널 링크에 접속하시어 해당 채널에 '소리앨범 친구초대 이벤트 당첨자' 라고 메시지를 남겨주시기 바랍니다.",
                    style: TextStyle(
                        inherit: false, color: Colors.black, fontSize: 16)),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://pf.kakao.com/_csbDxj');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: const Text(
                    '시공간 카카오톡 채널 바로가기',
                    style: TextStyle(
                        inherit: false, color: Color.fromRGBO(162, 189, 242, 1), fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}