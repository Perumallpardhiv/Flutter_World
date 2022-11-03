import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import 'package:todo_firebase/main.dart';

class fruitDetector extends StatefulWidget {
  const fruitDetector({super.key});

  @override
  State<fruitDetector> createState() => _fruitDetectorState();
}

class _fruitDetectorState extends State<fruitDetector> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  runModelOnStreamFrames() async {
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: imgCamera!.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: imgCamera!.height,
      imageWidth: imgCamera!.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );

    result = '';

    recognitions!.forEach((response) {
      result += response['label'] +
          ' ' +
          (response['confidence'] as double).toStringAsFixed(2) +
          '\n\n';
    });
    setState(() {
      result;
    });
    isWorking = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Fruit Detector',
                style: GoogleFonts.lato(
                          fontSize: 25,
                          color: Get.isDarkMode ? Colors.white : Colors.black),
              ),
              Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 100.0),
                      height: 220,
                      width: 320,
                      child: Image.asset('assets/frame.webp'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 65.0),
                        height: 270,
                        width: 360,
                        child: imgCamera == null
                            ? Container(
                                height: 270,
                                width: 360,
                                child: Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.pink,
                                  size: 60,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 55.0),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: TextStyle(
                        backgroundColor: Colors.black,
                        fontSize: 25.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
