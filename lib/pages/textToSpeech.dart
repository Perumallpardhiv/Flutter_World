import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class textTospeech extends StatefulWidget {
  const textTospeech({super.key});

  @override
  State<textTospeech> createState() => _textTospeechState();
}

class _textTospeechState extends State<textTospeech> {
  FlutterTts flutterTts = FlutterTts();
  TextEditingController controller = TextEditingController();
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String langCode = "en-US";

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    languages = List<String>.from(await flutterTts.getLanguages);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
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
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Text to Speech',
              style: GoogleFonts.lato(
                  fontSize: 25,
                  color: Get.isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(
              width: 200,
              height: 60,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Text',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("Speak"),
                  onPressed: _speak,
                ),
                ElevatedButton(
                  child: Text("Stop"),
                  onPressed: _stop,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      "Volume",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: volume,
                    onChanged: (value) {
                      setState(() {
                        volume = value;
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                        double.parse((volume).toStringAsFixed(2)).toString(),
                        style: const TextStyle(fontSize: 17)),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      "Pitch",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  Slider(
                    min: 0.5,
                    max: 2.0,
                    value: pitch,
                    onChanged: (value) {
                      setState(() {
                        pitch = value;
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                        double.parse((pitch).toStringAsFixed(2)).toString(),
                        style: const TextStyle(fontSize: 17)),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      "Speech Rate",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    value: speechRate,
                    onChanged: (value) {
                      setState(() {
                        speechRate = value;
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                        double.parse((speechRate).toStringAsFixed(2))
                            .toString(),
                        style: const TextStyle(fontSize: 17)),
                  )
                ],
              ),
            ),
            if (languages != null)
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const Text(
                      "Language :",
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DropdownButton<String>(
                      focusColor: Colors.white,
                      value: langCode,
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.black,
                      items: languages!
                          .map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                          value: value!,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          langCode = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void initSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(langCode);
  }

  void _speak() async {
    initSetting();
    await flutterTts.speak(controller.text);
  }

  void _stop() async {
    await flutterTts.stop();
  }
}
