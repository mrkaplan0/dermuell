import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';

class IcsUtils {
  static DateTime? toDateTime(dynamic icsDateTime) {
    if (icsDateTime == null || icsDateTime is! IcsDateTime) {
      return null;
    }
    final String dtString = icsDateTime.dt;
    try {
      DateTime parsedDateTime;

      if (dtString.length == 8 && !dtString.contains('T')) {
        // Already date only format (YYYYMMDD)
        final year = dtString.substring(0, 4);
        final month = dtString.substring(4, 6);
        final day = dtString.substring(6, 8);
        parsedDateTime = DateTime.parse('$year-$month-$day');
      } else {
        // Full datetime format - parse and extract date only
        parsedDateTime = DateTime.parse(dtString);
      }

      // Return only the date part (without time)
      return DateTime(
        parsedDateTime.year,
        parsedDateTime.month,
        parsedDateTime.day,
      );
    } catch (e) {
      debugPrint('Error parsing IcsDateTime string: "$dtString". Error: $e');
      return null;
    }
  }
}
