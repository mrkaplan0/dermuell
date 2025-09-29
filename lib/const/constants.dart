import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    var myBox = Hive.box('dataBox');
    var collectionsTypes = myBox.get(
      'address',
      defaultValue: {},
    )['collectionTypes'];
    for (var element in collectionsTypes) {
      if (element['id'] == id) {
        return element['name'].toString();
      }
    }
    return "Unknown";
  }

  static Color? getColorFromFraktionName(String fraktionName) {
    switch (fraktionName.toLowerCase()) {
      case 'bio':
        return Colors.brown;
      case 'gel':
        return const Color.fromARGB(255, 207, 192, 49);
      case 'alt' || 'pap':
        return Colors.green;
      case 'res':
        return Colors.black;
      case 'wei':
        return Colors.red;
      case 'grü':
        return Colors.green[200];
      default:
        return Colors.blueGrey;
    }
  }

  static Icon getIconFromFraktionName(String fraktionName) {
    switch (fraktionName.toLowerCase()) {
      case 'bio':
        return Icon(Icons.grass);
      case 'gel':
        return Icon(Icons.recycling);
      case 'alt' || 'pap':
        return Icon(Icons.menu_book);
      case 'res':
        return Icon(Icons.delete, color: Colors.white);
      case 'wei':
        return Icon(Icons.forest);
      case 'grü':
        return Icon(Icons.eco);
      default:
        return Icon(Icons.data_saver_off);
    }
  }
}
