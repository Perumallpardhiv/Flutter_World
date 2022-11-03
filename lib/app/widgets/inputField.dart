import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyInputField extends StatelessWidget {
  MyInputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.widget})
      : super(key: key);
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                  fontSize: 18,
                  color: Get.isDarkMode ? Colors.white : Colors.black),
            ),
            Container(
              padding: const EdgeInsets.only(left: 12),
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: widget != null ? true : false,
                      autofocus: false,
                      cursorColor:
                          Get.isDarkMode ? Colors.grey[100] : Colors.grey[400],
                      controller: controller,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Get.isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: GoogleFonts.lato(
                              fontSize: 16,
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: context.theme.backgroundColor,
                                  width: 0))),
                    ),
                  ),
                  widget == null
                      ? Container()
                      : Container(
                          child: widget,
                        )
                ],
              ),
            )
          ],
        ));
  }
}
