import 'package:dermuell/const/collection_types.dart';
import 'package:flutter/material.dart';

class XConst {
  static const Color primaryColor = Color(0xFF472C1B);
  static const Color secondaryColor = Color(0xFF7D451B);
  static const Color thirdColor = Color(0xFFD19C1D);
  static const Color fourthColor = Color(0xFFD7F75B);
  static const Color fifthColor = Color(0xFF9BE564);
  static const Color sixthColor = Color(0xFF64722A);
  static const Color bgColor = Color(0xFFF5F5F5);

  static const TextStyle myBigTitleTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: fifthColor,
    fontFamily: 'FingerPaint',
  );

  static InputDecorationTheme dropdownMenuDecoration = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
  );

  static Widget leadingIcon = Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.asset("assets/images/logo.png", width: 10, height: 10),
  );

  static String setCollTypeName(int id) {
    for (var element in collectionsTypes) {
      if (element['id'] == id) {
        return element['name'].toString();
      }
    }
    return "Unknown";
  }
}
