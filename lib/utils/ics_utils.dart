import 'package:icalendar_parser/icalendar_parser.dart';

class IcsUtils {
  static DateTime? toDateTime(dynamic icsDateTime) {
    if (icsDateTime == null || icsDateTime is! IcsDateTime) {
      return null;
    }
    final String dtString = icsDateTime.dt;
    try {
      if (dtString.length == 8 && !dtString.contains('T')) {
        final year = dtString.substring(0, 4);
        final month = dtString.substring(4, 6);
        final day = dtString.substring(6, 8);
        return DateTime.parse('$year-$month-$day');
      }
      return DateTime.parse(dtString);
    } catch (e) {
      print('Error parsing IcsDateTime string: "$dtString". Error: $e');
      return null;
    }
  }
}
