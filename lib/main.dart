import 'package:camera/camera.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_firebase/app/values/theme_service.dart';
import 'package:todo_firebase/app/values/themes.dart';
import 'package:todo_firebase/data/local/alarm_helper.dart';
import 'package:todo_firebase/data/local/db_helper.dart';
import 'package:todo_firebase/pages/HomePage.dart';
import 'package:todo_firebase/pages/SignupPage.dart';
import 'package:todo_firebase/pages/addTodo.dart';
import 'package:todo_firebase/pages/currencyConvertor.dart';
import 'package:todo_firebase/pages/faceDetector.dart';
import 'package:todo_firebase/pages/fruitDetector.dart';
import 'package:todo_firebase/pages/maskDetector.dart';
import 'package:todo_firebase/pages/speechToText.dart';
import 'package:todo_firebase/pages/stopWatch.dart';
import 'package:todo_firebase/pages/textToSpeech.dart';
import 'package:todo_firebase/pages/toDoList.dart';
import 'package:todo_firebase/service/auth_service.dart';
import 'package:workmanager/workmanager.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    
final FlutterTts flutterTts = FlutterTts();

List<CameraDescription>? cameras;

speak(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    try {
      speak(taskName);
      print(taskName);
    } catch (err) {
      print(err);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await DBHelper.initDb();
  AlarmHelper.alarmHelper.initializeDatabase();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  cameras = await availableCameras();


  var initializationSettingsAndroid =
      const AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthClass authClass = AuthClass();
  // Widget currentPage = SignUpPage();

  @override
  void initState() {
    super.initState();
    // checkLogin();
  }

  // void checkLogin() async {
  //   String? userCredential = await authClass.getToken();

  //   if (userCredential != null) {
  //     setState(() {
  //       currentPage = homePage();
  //     });
  //   } else {
  //     setState(() {
  //       currentPage = SignUpPage();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeServices().theme,
      theme: Themes.light,
      darkTheme: Themes.dark,
      debugShowCheckedModeBanner: false,
      home: FeatureDiscovery(
        recordStepsInSharedPreferences: false,
        child: homePage(),
      ),
      initialRoute: '/',
      routes: {
        '/todoList' : (context) => toDoList(),
        '/addtodo' : (context) => addTodo(),
        '/stopwatch' : (context) => stopWatch(),
        '/face' : (context) => faceDetector(),
        '/fruit' : (context) => fruitDetector(),
        '/mask' : (context) => maskDetector(),
        '/money' : (context) => currency(),
        '/stt' : (context) => speechToText(),
        '/tts' : (context) => textTospeech(),
        '/logout' : (context) => SignUpPage(),
      },
    );
  }
}
