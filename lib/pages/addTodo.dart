import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/app/core/task_controller.dart';
import 'package:todo_firebase/app/model/alarm_info.dart';
import 'package:todo_firebase/app/model/task.dart';
import 'package:todo_firebase/app/widgets/inputField.dart';
import 'package:todo_firebase/data/local/alarm_helper.dart';
import 'package:todo_firebase/main.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class addTodo extends StatefulWidget {
  const addTodo({super.key});

  @override
  State<addTodo> createState() => _addTodoState();
}

class _addTodoState extends State<addTodo> {
  // late tz.TZDateTime _alarmTime;
  // late bool _isRepeatSelected =  ? false : true;
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late String alarmTitle;
  int alarmId = 1;
  late int _isCompleted;
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _endTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(Duration(hours: 3)))
      .toString();
  String _selectedRepeat = 'None';
  List<String> repeatList = ["None", "Daily"];
  int _selectedColor = 0;
  final TaskController _taskController = Get.put(TaskController());
  DateTime? _alarmTime;
  AlarmHelper alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: FutureBuilder(
        future: _alarms,
        builder: (context, snapshot) {
          return Container(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Tasks',
                    style: GoogleFonts.lato(
                        fontSize: 22,
                        color: Get.isDarkMode ? Colors.white : Colors.black),
                  ),
                  MyInputField(
                    title: 'Title',
                    hint: 'Enter Your title',
                    controller: _titleController,
                  ),
                  MyInputField(
                    title: 'Note',
                    hint: 'Enter Your note',
                    controller: _noteController,
                  ),
                  MyInputField(
                    title: 'Date',
                    hint: DateFormat.yMd().format(_selectedDate),
                    widget: IconButton(
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _getDateFromUser();
                      },
                    ),
                  ),
                  Row(children: [
                    Expanded(
                        child: MyInputField(
                      title: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _getTimerFromUser(isStartTime: true);
                        },
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyInputField(
                        title: 'End Time',
                        hint: _endTime,
                        widget: IconButton(
                          color: Colors.grey,
                          icon: const Icon(Icons.access_time_rounded),
                          onPressed: () {
                            _getTimerFromUser(isStartTime: false);
                          },
                        ),
                      ),
                    )
                  ]),
                  MyInputField(
                    title: 'Repeat',
                    hint: _selectedRepeat,
                    widget: DropdownButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      iconSize: 28,
                      elevation: 4,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Get.isDarkMode ? Colors.white : Colors.black),
                      underline: Container(height: 0),
                      items: repeatList
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                                  child: Text(
                                    value,
                                  ),
                                  value: value))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRepeat = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _colorPalet(),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isCompleted = 0;
                          });
                          _validateTask();
                          onSaveAlarm();
                        },
                        child: Container(
                          width: 90,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue),
                          child: Center(
                            child: Text(
                              'Create Task',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _validateTask() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // var check = DateTime.now().millisecondsSinceEpoch;
      // var check2 = DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch;
      var date = _selectedDate.millisecondsSinceEpoch;
      print(DateTime.fromMillisecondsSinceEpoch(date, isUtc: false).day);
      print(DateTime.fromMillisecondsSinceEpoch(date, isUtc: false).month);
      print(DateTime.fromMillisecondsSinceEpoch(date, isUtc: false).year);
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar('Required', 'All fields are required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
              Get.isDarkMode ? Color.fromARGB(255, 40, 40, 40) : Colors.white,
          icon: Icon(
            Icons.warning,
            color: Colors.red,
          ),
          margin: EdgeInsets.all(20));
    }
  }

  // void callback() {
  //   print("Alarm Fired Off ${DateTime.now()}");
  // }

  void scheduleAlarm(
      DateTime scheduleNotificationDateTime, AlarmInfo alarmInfo) async {
    // var scheduleNotificationDateTime =
    //     DateTime.now().add(Duration(seconds: 10));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      alarmInfo.id.toString(),
      alarmInfo.id.toString(),
      channelDescription: "${alarmInfo.id.toString()} Alarm Time",
      icon: 'ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      styleInformation: DefaultStyleInformation(true, true),
      ticker: 'ticker',
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'a_long_cold_sting.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    print("notif : ${alarmInfo.notifSound}");
    // speak(alarmInfo.notifSound!);
    Workmanager().registerOneOffTask(
        alarmInfo.id.toString(), alarmInfo.notifSound!,
        initialDelay: Duration(
            hours: scheduleNotificationDateTime.hour - DateTime.now().hour,
            minutes:
                scheduleNotificationDateTime.minute - DateTime.now().minute,
            seconds: 0));
    if (alarmInfo.isPending == 1) {
      await flutterLocalNotificationsPlugin.schedule(
        alarmInfo.id,
        alarmInfo.title,
        alarmInfo.body,
        scheduleNotificationDateTime,
        platformChannelSpecifics,
        payload: 'New Payload',
      );
      alarmInfo.isPending = 0;
    } else {
      deleteAlarm(alarmInfo.id, alarmInfo);
    }
  }

  void deleteAlarm(int id, AlarmInfo alarmInfo) async {
    await alarmHelper.delete(id);
    //unsubscribe for notification
    await flutterLocalNotificationsPlugin.cancel(alarmInfo.id);
    loadAlarms();
  }

  void _addTaskToDb() async {
    int val = await _taskController.addTask(
        task: Task(
            note: _noteController.text,
            title: _titleController.text,
            date: DateFormat.yMd().format(_selectedDate),
            startTime: _startTime,
            endTime: _endTime,
            repeat: _selectedRepeat,
            color: _selectedColor,
            isCompleted: _isCompleted));
    print('My id is $val');
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("assets/profile.png"),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Column _colorPalet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: GoogleFonts.lato(
              fontSize: 18,
              color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        SizedBox(
          height: 8,
        ),
        Wrap(
          children: List<Widget>.generate(
            3,
            (index) => GestureDetector(
              onTap: () {
                _selectedColor = index;
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: index == 0
                      ? Colors.blue
                      : index == 1
                          ? Color(0xffff4667)
                          : Color(0xffffb746),
                  child: _selectedColor == index
                      ? Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2222));

    setState(() {
      if (_pickerDate != null) {
        _selectedDate = _pickerDate;
      }
    });
  }

  _getTimerFromUser({required bool isStartTime}) async {
    // var pickedTime = await _showTimePicker();
    var selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      final now = DateTime.now();
      var selectedDateTime = DateTime(now.year, now.month, _selectedDate.day,
          selectedTime.hour, selectedTime.minute);
      _alarmTime = selectedDateTime;
      // setModalState(() {
      if (isStartTime == true) {
        _startTime = DateFormat('hh:mm a').format(selectedDateTime);
      } else {
        _endTime = DateFormat('hh:mm a').format(selectedDateTime);
      }
      // });
      setState(() {});
    }
    // String? _formatedTime = pickedTime.format(context);
    // if (pickedTime == null) {
    //   print("Time canceled");
    // } else if (isStartTime == true) {
    //   _startTime = _formatedTime!;
    // } else if (isStartTime == false) {
    //   _endTime = _formatedTime!;
    // }
  }

  // _showTimePicker() {
  //   return showTimePicker(
  //     initialEntryMode: TimePickerEntryMode.input,
  //     context: context,
  //     initialTime: TimeOfDay(
  //       hour: int.parse(_startTime.split(':')[0]),
  //       minute: int.parse(_startTime.split(':')[1].split(' ')[0]),
  //     ),
  //   );
  // }

  void onSaveAlarm() async {
    DateTime? scheduleAlarmDateTime;
    scheduleAlarmDateTime = _alarmTime;
    // scheduleAlarm();
    int id = await alarmHelper.getId();
    var alarmInfo = AlarmInfo(
      id: id,
      alarmDateTime:
          scheduleAlarmDateTime!.add(scheduleAlarmDateTime.timeZoneOffset),
      title: _titleController.text,
      body: _noteController.text,
      isPending: 1,
      isRepeat: _selectedRepeat == "None" ? 0 : 1,
      notifSound: _titleController.text,
    );
    await alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    loadAlarms();
  }
}
