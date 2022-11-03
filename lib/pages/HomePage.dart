import 'dart:math';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_firebase/app/core/task_controller.dart';
import 'package:todo_firebase/pages/SignupPage.dart';
import 'package:todo_firebase/pages/convertors.dart';
import 'package:todo_firebase/pages/mlWorld.dart';
import 'package:todo_firebase/pages/toDoList.dart';
import 'package:todo_firebase/service/auth_service.dart';

class homePage extends StatefulWidget {
  homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late int page = 1;
  double width = 0.0;
  double height = 0.0;
  late ScrollController scrollController;
  List<DateTime> currentMonthList = List.empty();
  late String alarmTitle;
  DateTime currentDateTime = DateTime.now();
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final _taskController = Get.put(TaskController());
  bool pressing = false;
  late Offset _startPosition;
  int alarmId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(context, <String>[
        'feature1',
        'feature2',
      ]);
    });
    _taskController.getTasks();
  }

  double value = 0;
  AuthClass authClass = AuthClass();
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 66, 165, 245),
                  Color.fromARGB(255, 50, 141, 246),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )),
            ),
            SafeArea(
              child: Container(
                width: 200.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    DrawerHeader(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/profile.png"),
                        ),
                        SizedBox(
                          height: 9,
                        ),
                        Text(
                          "Flutter World",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    )),
                    SizedBox(
                      height: 130,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            onTap: () {
                              setState(() {
                                value = 0;
                                page = 1;
                              });
                            },
                            leading: Icon(
                              Icons.watch_later_outlined,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Clock World",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                value = 0;
                                page = 2;
                              });
                            },
                            leading: Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                            ),
                            title: Text(
                              "ML World",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                value = 0;
                                page = 3;
                              });
                            },
                            leading: Icon(
                              Icons.change_circle_outlined,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Convertors",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          // ListTile(
                          //   onTap: () async {
                          //     await authClass.logout(context);
                          //     Navigator.pushAndRemoveUntil(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (builder) => SignUpPage()),
                          //         (route) => false);
                          //   },
                          //   leading: Icon(
                          //     Icons.logout,
                          //     color: Colors.white,
                          //   ),
                          //   title: Text(
                          //     "Log out",
                          //     style: TextStyle(color: Colors.white),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: value),
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 300),
              builder: (_, double val, __) {
                return (Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..setEntry(0, 3, 200 * val)
                    ..rotateY((pi / 6) * val),
                  child: Scaffold(
                    backgroundColor: Get.isDarkMode
                        ? Color.fromARGB(255, 52, 52, 52)
                        : Color.fromARGB(255, 89, 147, 195),
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: DescribedFeatureOverlay(
                        featureId: 'feature1',
                        targetColor:
                            Get.isDarkMode ? Colors.black : Colors.white,
                        textColor: Get.isDarkMode ? Colors.black : Colors.white,
                        backgroundColor: Colors.blue,
                        contentLocation: ContentLocation.below,
                        title: Text(
                          'Menu Icon',
                          style: TextStyle(fontSize: 30.0),
                        ),
                        pulseDuration: Duration(seconds: 1),
                        enablePulsingAnimation: true,
                        overflowMode: OverflowMode.clipContent,
                        openDuration: Duration(seconds: 1),
                        description: Text(
                          'Click or Swipe Right\n For more features',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        tapTarget: Icon(
                          Icons.menu,
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              value == 0 ? value = 1 : value = 0;
                            });
                          },
                          child: Icon(
                            Icons.menu,
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    body: page == 1
                        ? toDoList()
                        : page == 2
                            ? MLWorld()
                            : convertor(),
                  ),
                ));
              },
            ),
            GestureDetector(onHorizontalDragStart: (er) {
              final startPosition = er.globalPosition;
              setState(() {
                _startPosition = startPosition;
              });
              // print(_startPosition.dx.toStringAsFixed(2));
              // print(_startPosition.dy.toStringAsFixed(3));
            }, onHorizontalDragUpdate: (e) {
              // print(e.delta.dy.toStringAsFixed(4));
              if (e.delta.dx > 0) {
                // print(e.delta.dx);
                setState(() {
                  value = 1;
                });
              } else {
                if (e.delta.dx <= 0) {
                  setState(() {
                    value = 0;
                  });
                }
              }
            }),
          ],
        ),
      ),
    );
  }
}
