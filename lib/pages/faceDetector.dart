import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

class faceDetector extends StatefulWidget {
  const faceDetector({super.key});

  @override
  State<faceDetector> createState() => _faceDetectorState();
}

class _faceDetectorState extends State<faceDetector> {
  File? _imageFile;
  String _mlResult = '<no result>';
  final _picker = ImagePicker();

  Future<bool> _pickImage() async {
    setState(() => this._imageFile = null);
    final File? imageFile = await showDialog<File>(
      context: context,
      builder: (ctx) => SimpleDialog(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take picture'),
            onTap: () async {
              final XFile? pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              if (mounted && pickedFile != null) {
                Navigator.pop(ctx, File(pickedFile.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Pick from gallery'),
            onTap: () async {
              try {
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (mounted && pickedFile != null) {
                  Navigator.pop(ctx, File(pickedFile.path));
                }
              } catch (e) {
                // print(e);
                Navigator.pop(ctx, null);
              }
            },
          ),
        ],
      ),
    );
    if (mounted && imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick one image first.')),
      );
      return false;
    }
    setState(() => this._imageFile = imageFile);
    return true;
  }

  Future<void> _faceDetect() async {
    setState(() => this._mlResult = '<no result>');
    if (await _pickImage() == false) {
      return;
    }
    String result = '';
    final InputImage inputImage = InputImage.fromFile(this._imageFile!);
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    );
    final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(options);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    result += 'Detected ${faces.length} faces.\n';
    for (final Face face in faces) {
      final Rect boundingBox = face.boundingBox;
      // Head is rotated to the right rotY degrees
      final double rotY = face.headEulerAngleY!;
      // Head is tilted sideways rotZ degrees
      final double rotZ = face.headEulerAngleZ!;
      result += '\n# Face:\n '
          'bbox=$boundingBox\n '
          'rotY=$rotY\n '
          'rotZ=$rotZ\n ';
      final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
        result += 'leftEarPos=$leftEarPos\n ';
      }
      final FaceLandmark? rightEar = face.landmarks[FaceLandmarkType.rightEar];
      if (rightEar != null) {
        final Point<int> rightEarPos = rightEar.position;
        result += 'rigthEarPos=$rightEarPos\n ';
      }
      if (face.smilingProbability != null) {
        final double smileProb = face.smilingProbability!;
        result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
      }
      if (face.trackingId != null) {
        final int id = face.trackingId!;
        result += 'id=$id\n ';
      }
    }
    if (result.isNotEmpty) {
      setState(() => this._mlResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ListView(
          children: [
            if (this._imageFile == null)
              Padding(
                padding: EdgeInsets.all(15),
                child: Placeholder(
                  fallbackHeight: 200.0,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(15),
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(this._imageFile!),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: ElevatedButton(
                onPressed: this._faceDetect,
                child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Text(
                      "Face Detector",
                      style: TextStyle(fontSize: 18),
                    )),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Result:',
                style: GoogleFonts.notoSansMono(
                  fontSize: 25,
                  color: Get.isDarkMode ? Color.fromARGB(255, 240, 235, 235) : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Expanded(
                child: Text(
                  this._mlResult,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    color: Get.isDarkMode ? Color.fromARGB(255, 240, 235, 235) : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
