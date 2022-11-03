import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:transparent_image/transparent_image.dart';

class maskDetector extends StatefulWidget {
  const maskDetector({super.key});

  @override
  State<maskDetector> createState() => _maskDetectorState();
}

class _maskDetectorState extends State<maskDetector> {
  File? _imageFile;
  final _picker = ImagePicker();
  List _predictions = [];

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  loadModels() async {
    await Tflite.loadModel(
        model: 'assets/models/model.tflite', labels: 'assets/texts/lables.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  detect_img(File _imageFile) async {
    var prediction = await Tflite.runModelOnImage(
      path: _imageFile.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _predictions = prediction!;
    });
  }

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
              var pickedFile =
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
                var pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (mounted && pickedFile != null) {
                  Navigator.pop(ctx, File(pickedFile.path));
                }
              } catch (e) {
                print(e);
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
    // print('picked image: ${this._imageFile}');
    detect_img(_imageFile!);
    return true;
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
                onPressed: this._pickImage,
                child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Text(
                      "Mask Detector",
                      style: TextStyle(fontSize: 18),
                    )),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _predictions.length > 0
                      ? _predictions[0]['label'].toString()
                      : " ",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    color: Get.isDarkMode
                        ? Color.fromARGB(255, 240, 235, 235)
                        : Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _predictions.length > 0
                      ? 'Confidence : ${_predictions[0]['confidence'].toString()}'
                      : " ",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    color: Get.isDarkMode
                        ? Color.fromARGB(255, 240, 235, 235)
                        : Colors.black,
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
