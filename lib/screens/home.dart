import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            IconButton(
              icon: Icon(
                CupertinoIcons.camera_fill,
                color: Colors.black54,
                size: 30,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(CupertinoIcons.photo, color: Colors.black54, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  Icon(CupertinoIcons.search, color: Colors.black54, size: 30),
              onPressed: () {
                Get.toNamed('/search');
              },
            )
          ]),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 20,
                  itemBuilder: (context, index) => Column(
                        children: [
                          Text(index.toString()),
                          GridView.count(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 5,
                              children: List.generate(
                                  8,
                                  (index2) => Card(
                                      child: Text(index2.toString()),
                                      color: Colors.white38)))
                        ],
                      )),
            ),
            ElevatedButton(
                child: Text('to search'),
                onPressed: () {
                  Get.toNamed('/search');
                }),
            ElevatedButton(
                child: Text('to detail'),
                onPressed: () {
                  Get.toNamed('/image_detail');
                })
          ]),
        ));
  }
}
