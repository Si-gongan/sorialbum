import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black54,
          title: Row(
            children: [
              Expanded(
                  child: Container(
                height: 40,
                child: TextField(
                    textAlignVertical: TextAlignVertical.bottom,
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: '찾고 싶은 사진을 묘사해보세요...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide:
                                BorderSide(color: Colors.black54, width: 2)))),
              )),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () {},
            )
          ]),
    );
  }
}
