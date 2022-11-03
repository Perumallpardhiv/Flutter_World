import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

class textRec extends StatefulWidget {
  const textRec({super.key});

  @override
  State<textRec> createState() => _textRecState();
}

class _textRecState extends State<textRec> {
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

  Future<void> _text() async {
    setState(() => this._mlResult = '<no result>');
    if (await _pickImage() == false) {
      return;
    }
    String result = '';
    final InputImage inputImage = InputImage.fromFile(this._imageFile!);
    final TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);
    final String text = recognizedText.text;
    debugPrint('Recognized text: "$text"');
    result += 'Detected ${recognizedText.blocks.length} text blocks.\n';
    for (final TextBlock block in recognizedText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;
      result += '\n# Text block:\n '
          'bbox=$boundingBox\n '
          'cornerPoints=$cornerPoints\n '
          'text=$text\n languages=$languages\n';
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
                onPressed: _text,
                child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Text(
                      "Text Recogniser",
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
                  color: Get.isDarkMode
                      ? Color.fromARGB(255, 240, 235, 235)
                      : Colors.black,
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
