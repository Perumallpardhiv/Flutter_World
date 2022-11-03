import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class speechToText extends StatefulWidget {
  const speechToText({super.key});

  @override
  State<speechToText> createState() => _speechToTextState();
}

class _speechToTextState extends State<speechToText> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and Start Speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(top: 25, left: 7, right: 7),
      child: Scaffold(
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
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
            child: Text(
              _text,
              style: TextStyle(
                fontSize: 30.0,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Colors.blue,
          endRadius: 75.0,
          duration: Duration(milliseconds: 2000),
          repeatPauseDuration: Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus : $val'),
        onError: (val) => print('onError : $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (val) => setState(
            () {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            },
          ),
        );
      } else {
        setState(() {
          _isListening = false;
        });
        _speech.stop();
      }
    }
  }
}
