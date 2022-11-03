import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:todo_firebase/app/values/theme_service.dart';
import 'package:todo_firebase/pages/addTodo.dart';
import 'package:todo_firebase/pages/currencyConvertor.dart';
import 'package:todo_firebase/pages/speechToText.dart';
import 'package:todo_firebase/pages/textToSpeech.dart';

class convertor extends StatefulWidget {
  const convertor({super.key});

  @override
  State<convertor> createState() => _convertorState();
}

class _convertorState extends State<convertor> {
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
                backgroundColor:
                    Get.isDarkMode ? Colors.white : Colors.grey[700],
                onTap: () => ThemeServices().switchTheme(),
              ),
              SpeedDialChild(
                  child: Icon(Icons.currency_exchange_outlined,
                      color: Get.isDarkMode ? Colors.black : Colors.white),
                  label: 'Currency Convertor',
                  backgroundColor:
                      Get.isDarkMode ? Colors.white : Colors.grey[700],
                  onTap: () {
                    setState(() {
                      page = 1;
                    });
                  }),
              SpeedDialChild(
                  child: Icon(Icons.text_fields,
                      color: Get.isDarkMode ? Colors.black : Colors.white),
                  label: 'Speech to Text',
                  backgroundColor:
                      Get.isDarkMode ? Colors.white : Colors.grey[700],
                  onTap: () {
                    setState(() {
                      page = 2;
                    });
                  }),
              SpeedDialChild(
                  child: Icon(Icons.audiotrack_outlined,
                      color: Get.isDarkMode ? Colors.black : Colors.white),
                  label: 'Text to Speech',
                  backgroundColor:
                      Get.isDarkMode ? Colors.white : Colors.grey[700],
                  onTap: () {
                    setState(() {
                      page = 3;
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
            child: page == 1 ? currency() : page == 2 ? speechToText() : textTospeech(),
          )),
    );
  }
}
