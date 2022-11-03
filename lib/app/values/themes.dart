import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    backgroundColor: Colors.white,
  );

  static final dark = ThemeData(
    primaryColor: Color(0xff121212),
    brightness: Brightness.dark,
    backgroundColor: Color.fromARGB(255, 69, 69, 69),
  );
}
