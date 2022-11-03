import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/app/core/task_controller.dart';
import 'package:todo_firebase/app/model/task.dart';
import 'package:todo_firebase/app/values/theme_service.dart';
import 'package:todo_firebase/app/widgets/taskTile.dart';
import 'package:todo_firebase/pages/addTodo.dart';
import 'package:todo_firebase/pages/stopWatch.dart';

class toDoList extends StatefulWidget {
  const toDoList({Key? key}) : super(key: key);

  @override
  State<toDoList> createState() => _toDoListState();
}

class _toDoListState extends State<toDoList> {
  late int page = 1;
  final isDialOpen = ValueNotifier(false);
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taskController.getTasks();
  }

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
          floatingActionButton: DescribedFeatureOverlay(
            featureId: 'feature2',
            targetColor: Get.isDarkMode ? Colors.black : Colors.white,
            textColor: Get.isDarkMode ? Colors.black : Colors.white,
            backgroundColor: Colors.blue,
            contentLocation: ContentLocation.trivial,
            title: Text(
              'More Features',
              style: TextStyle(fontSize: 30.0),
            ),
            pulseDuration: Duration(seconds: 1),
            enablePulsingAnimation: true,
            barrierDismissible: false,
            overflowMode: OverflowMode.wrapBackground,
            openDuration: Duration(seconds: 1),
            description: Text(
              'This is used to\n go to other features',
              style: TextStyle(fontSize: 17.0),
            ),
            tapTarget: SpeedDial(
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
                    child: Icon(Icons.list_alt,
                        color: Get.isDarkMode ? Colors.black : Colors.white),
                    label: 'To-Do',
                    backgroundColor:
                        Get.isDarkMode ? Colors.white : Colors.grey[700],
                    onTap: () {
                      setState(() {
                        page = 1;
                      });
                    }),
                SpeedDialChild(
                    child: Icon(Icons.timer,
                        color: Get.isDarkMode ? Colors.black : Colors.white),
                    label: 'StopWatch',
                    backgroundColor:
                        Get.isDarkMode ? Colors.white : Colors.grey[700],
                    onTap: () {
                      setState(() {
                        page = 2;
                      });
                    }),
              ],
            ),
            child: SpeedDial(
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
                    child: Icon(Icons.list_alt,
                        color: Get.isDarkMode ? Colors.black : Colors.white),
                    label: 'To-Do',
                    backgroundColor:
                        Get.isDarkMode ? Colors.white : Colors.grey[700],
                    onTap: () {
                      setState(() {
                        page = 1;
                      });
                    }),
                SpeedDialChild(
                    child: Icon(Icons.timer,
                        color: Get.isDarkMode ? Colors.black : Colors.white),
                    label: 'StopWatch',
                    backgroundColor:
                        Get.isDarkMode ? Colors.white : Colors.grey[700],
                    onTap: () {
                      setState(() {
                        page = 2;
                      });
                    }),
              ],
            ),
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
            child: page == 1 ? toDopage() : stopWatch(),
          )),
    );
  }

  Column toDopage() {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: size.height * .02,
        ),
        _addTaskBar(),
        _addDateBar(size),
        SizedBox(
          height: size.height * .02,
        ),
        const Divider(
          height: 2,
          color: Colors.grey,
        ),
        SizedBox(
          height: size.height * .02,
        ),
        _showTasks(size),
      ],
    );
  }

  Container _addDateBar(size) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 15),
      child: DatePicker(
        DateTime.now(),
        height: size.height * .125,
        width: size.height * .09,
        initialSelectedDate: DateTime.now(),
        selectionColor: Colors.blue,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
            fontSize: 18, color: Get.isDarkMode ? Colors.white : Colors.black),
        dayTextStyle: GoogleFonts.lato(
            fontSize: 16, color: Get.isDarkMode ? Colors.white : Colors.black),
        monthTextStyle: GoogleFonts.lato(
            fontSize: 16, color: Get.isDarkMode ? Colors.white : Colors.black),
        onDateChange: (date) {
          _selectedDate = date;
          setState(() {});
        },
      ),
    );
  }

  Container _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd().format(DateTime.now()),
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white : Colors.black),
                ),
                Text(
                  'Today',
                  style: GoogleFonts.lato(
                      fontSize: 22,
                      color: Get.isDarkMode ? Colors.white : Colors.black),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Get.to(() => addTodo());
              _taskController.getTasks();
            },
            child: Container(
              width: 90,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  "+Add Task",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showTasks(size) {
    return Expanded(child: Obx(() {
      if (_taskController.taskList
          .where((p0) =>
              p0.date == DateFormat.yMd().format(_selectedDate) ||
              p0.repeat == "Daily")
          .isNotEmpty) {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              if (task.repeat == "Daily") {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat('HH:mm').format(date);
                print(myTime);

                return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 1,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showBottomSheet(context, task),
                            child: taskTile(task),
                          ),
                        ],
                      )),
                    ));
              } else if (task.date == DateFormat.yMd().format(_selectedDate)) {
                return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 1,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showBottomSheet(context, task),
                            child: taskTile(task),
                          ),
                        ],
                      )),
                    ));
              } else {
                return Container();
              }
            });
      } else {
        return AnimationConfiguration.staggeredGrid(
            position: 1,
            columnCount: 1,
            child: SlideAnimation(
                child: FadeInAnimation(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * .1,
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: size.height * size.width * .0003,
                    color: Colors.blue[900],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Nothing to do for today!\n\nCreate new task from "Add Task"\nbutton at the top.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Get.isDarkMode ? Colors.white : Colors.black),
                  )
                ],
              ),
            )));
      }
    }));
  }

  _showBottomSheet(context, Task task) {
    var size = MediaQuery.of(context).size;
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 4),
      height: size.height * 0.32,
      color: Get.isDarkMode ? Color(0xff121212) : Colors.white,
      child: Column(
        children: [
          Container(
            height: 5,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          Spacer(),
          task.isCompleted == 1
              ? _bottomSheetButton(
                  label: 'Task Not Completed',
                  onTap: () {
                    _taskController.markTaskNotCompleted(task.id!);
                    Get.back();
                  },
                  clr: Colors.blue,
                  context: context)
              : _bottomSheetButton(
                  label: 'Task Completed',
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: Colors.blue,
                  context: context),
          _bottomSheetButton(
              label: 'Delete Task',
              onTap: () {
                _taskController.delete(task);
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context),
          SizedBox(
            height: 20,
          ),
          _bottomSheetButton(
              label: 'Close',
              onTap: () {
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context,
              isClose: true),
          SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }

  _bottomSheetButton(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        height: 48,
        width: MediaQuery.of(context).size.width * .9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(
          label,
          style: isClose
              ? GoogleFonts.lato(
                  fontSize: 18,
                  color: Get.isDarkMode ? Colors.white : Colors.black)
              : GoogleFonts.lato(
                      fontSize: 18,
                      color: Get.isDarkMode ? Colors.white : Colors.black)
                  .copyWith(color: Colors.white),
        )),
      ),
    );
  }
}
