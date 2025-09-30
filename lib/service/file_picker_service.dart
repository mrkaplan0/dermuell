import 'dart:io';

import 'package:dermuell/model/event.dart';
import 'package:dermuell/utils/ics_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:icalendar_parser/icalendar_parser.dart';

class FilePickerService {
  static Future<bool> pickFile() async {
    final List<Event> events = [];
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        print("Selected file path: $filePath");
        File file = File(result.files.single.path!);
        final icsLines = await file.readAsLines();
        final iCalendar = ICalendar.fromLines(icsLines);
        print("Parsed iCalendar data: ${iCalendar.data}");

        final vevents = iCalendar.data.where(
          (component) => component['type'] == 'VEVENT',
        );

        // Step 3: Iterate over VEVENTs and map them to the custom Event model.
        for (final vevent in vevents) {
          final event = _mapVEventToEvent(vevent);
          if (event != null) {
            events.add(event);
          }
        }
        var myBox = Hive.box('dataBox');
        if (events.isNotEmpty) {
          await myBox.put('collectionEvents', events);
        }
        return true;
      } else {
        // User canceled the picker
        print("File picking was canceled by the user.");
        return false;
      }
    } catch (e) {
      print("Error picking file: $e");
      return false;
    }
  }

  /// Helper method to map a single VEVENT map to an [Event] object.
  /// Returns null if essential data (like UID or DTSTART) is missing or invalid.
  static Event? _mapVEventToEvent(Map<String, dynamic> vevent) {
    // --- Extract and validate essential fields ---
    final uid = vevent['uid'];
    if (uid == null) {
      // UID is critical for a unique ID. Skip if missing.
      return null;
    }

    final dtStart = IcsUtils.toDateTime(vevent['dtstart']);
    if (dtStart == null) {
      // A start date is essential. Skip if missing or invalid.
      return null;
    }

    // --- Extract optional and fallback fields ---
    final summary = vevent['summary'] as String? ?? 'No Title';

    // --- Determine 'gueltigAb' using priority-based fallback ---
    final created = IcsUtils.toDateTime(vevent['created']);
    final dtStamp = IcsUtils.toDateTime(vevent['dtstamp']);
    final gueltigAb = created ?? dtStamp ?? dtStart;

    // --- Handle application-specific fields ---
    // For fraktionID, we use a default value.
    // Advanced logic could parse it from 'summary' or 'description'.
    final fraktionID = -1; // Default value

    // --- Construct and return the Event object ---
    return Event(
      id: uid.toString().hashCode,
      title: summary,
      date: dtStart,
      fraktionID: fraktionID,
      gueltigAb: gueltigAb,
    );
  }
}



/* 
[{type: STANDARD, dtstart: IcsDateTime{tzid: null, dt: 19701025T030000}, rrule: FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU}, {type: DAYLIGHT, dtstart: IcsDateTime{tzid: null, dt: 19700329T020000}, rrule: FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU}, {type: VTIMEZONE}, {type: VALARM, trigger: -P0DT18H0M0S, action: DISPLAY, description: Glas}, {type: VEVENT, dtstart: IcsDateTime{tzid: null, dt: 20251014}, dtend: IcsDateTime{tzid: null, dt: 20251015}, transp: IcsTransp.transparent, location: Hauptstrasse 30 /1, 74385 Pleidelsheim, uid: 1759148828039-1@kundenportal.avl-lb.de, dtstamp: IcsDateTime{tzid: null, dt: 20250929T022708Z}, description: Leerungserinnerung, summary: Glas, class: PUBLIC, status: IcsStatus.confirmed}, {type: VALARM, trigger: -P0DT18H0M0S, action: DISPLAY, description: Glas}]}
  */

  /* 
  [{type: VEVENT, description: , dtend: IcsDateTime{tzid: null, dt: 20250105}, dtstamp: IcsDateTime{tzid: null, dt: 20250929T135555Z}, dtstart: IcsDateTime{tzid: null, dt: 20250104}, sequence: 0, summary: Leerung: DSD, uid: ffb5c780-793f-4605-8dff-fbfe37b472ed}, {type: VEVENT, description: , dtend: IcsDateTime{tzid: null, dt: 20250108}, dtstamp: IcsDateTime{tzid: null, dt: 20250929T135555Z}, dtstart: IcsDateTime{tzid: null, dt: 20250107}, sequence: 0, summary: Leerung: Restabfall, uid: 4ebf49eb-bd73-4cb3-a2bc-f0a00120df38}, {type: VEVENT, description: , dtend: IcsDateTime{tzid: null, dt: 20250109}, dtstamp: IcsDateTime{tzid: null, dt: 20250929T135555Z}, dtstart: IcsDateTime{tzid: null, dt: 20250108}, sequence: 0, summary: Leerung: Bioabfall, uid: 6431bfe9-b293-497a-ad9c-fd2d122c751e}]} */