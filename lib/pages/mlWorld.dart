import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:todo_firebase/app/values/theme_service.dart';
import 'package:todo_firebase/pages/addTodo.dart';
import 'package:todo_firebase/pages/faceDetector.dart';
import 'package:todo_firebase/pages/fruitDetector.dart';
import 'package:todo_firebase/pages/maskDetector.dart';
import 'package:todo_firebase/pages/stopWatch.dart';
import 'package:todo_firebase/pages/textRecogniser.dart';

class MLWorld extends StatefulWidget {
  const MLWorld({super.key});

  @override
  State<MLWorld> createState() => _MLWorldState();
}

class _MLWorldState extends State<MLWorld> {
  late int page = 1;
  final isDialOpen = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Get.isDarkMode ? Colors.white : Colors.grey[700],
          overlayColor: Colors.white,
          overlayOpacity: 0.4,
          spacing: 10,
          spaceBetweenChildren: 10,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
              child: Icon(
                  Get.isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_outlined,
                  color: Get.isDarkMode ? Colors.black : Colors.white),
              label: Get.isDarkMode ? 'Light' : 'Dark',
              backgroundColor: Get.isDarkMode ? Colors.white : Colors.grey[700],
              onTap: () => ThemeServices().switchTheme(),
            ),
            SpeedDialChild(
                child: Icon(Icons.face_outlined,
                    color: Get.isDarkMode ? Colors.black : Colors.white),
                label: 'Face Detection',
                backgroundColor:
                    Get.isDarkMode ? Colors.white : Colors.grey[700],
                onTap: () {
                  setState(() {
                    page = 1;
                  });
                }),
            SpeedDialChild(
                child: Icon(Icons.apple_outlined,
                    color: Get.isDarkMode ? Colors.black : Colors.white),
                label: 'Fruit Detector',
                backgroundColor:
                    Get.isDarkMode ? Colors.white : Colors.grey[700],
                onTap: () {
                  setState(() {
                    page = 2;
                  });
                }),
            SpeedDialChild(
                child: Icon(Icons.masks_outlined,
                    color: Get.isDarkMode ? Colors.black : Colors.white),
                label: 'Mask Detector',
                backgroundColor:
                    Get.isDarkMode ? Colors.white : Colors.grey[700],
                onTap: () {
                  setState(() {
                    page = 3;
                  });
                }),
            SpeedDialChild(
                child: Icon(Icons.image_outlined,
                    color: Get.isDarkMode ? Colors.black : Colors.white),
                label: 'Image to Text',
                backgroundColor:
                    Get.isDarkMode ? Colors.white : Colors.grey[700],
                onTap: () {
                  setState(() {
                    page = 4;
                  });
                }),
          ],
        ),
        backgroundColor: context.theme.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Get.isDarkMode
                  ? [
                      Color.fromARGB(255, 66, 66, 66),
                      Color.fromARGB(255, 52, 52, 52),
                    ]
                  : [
                      Color.fromARGB(255, 147, 200, 243),
                      Color.fromARGB(255, 89, 147, 195),
                    ],
              begin: Alignment.bottomCenter,
              end: Alignment.topRight,
            ),
          ),
          child: page == 1
              ? faceDetector()
              : page == 2
                  ? fruitDetector()
                  : page == 3
                      ? maskDetector()
                      : textRec(),
        ),
      ),
    );
  }
}
