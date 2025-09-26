import 'dart:async';
import 'dart:io';
import 'package:dermuell/model/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/material/time.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
          DarwinNotificationCategory(
            darwinNotificationCategoryText,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.text(
                'text_1',
                'Action 1',
                buttonTitle: 'Send',
                placeholder: 'Placeholder',
              ),
            ],
          ),
          DarwinNotificationCategory(
            darwinNotificationCategoryPlain,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Action 1'),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ];

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: darwinNotificationCategories,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    if (Platform.isWindows) {
      return;
    }
    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(), // Platforma özgü detaylar

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
  }

  Future<void> scheduleNotificationsForEvents(
    List<Event> events,
    TimeOfDay notificationTime,
  ) async {
    // Clear existing notifications before scheduling new ones
    await cancelAllNotifications();

    //Make a plan for each event
    for (final event in events) {
      // Calculate the date and time for the notification (1 day before at 23:00)
      final scheduledDate = tz.TZDateTime(
        tz.local,
        event.date.year,
        event.date.month,
        event.date.day - 1,
        notificationTime.hour,
        notificationTime.minute,
        0,
      );

      // Only schedule if the date is in the future
      if (scheduledDate.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: event.id,
          title: 'Nicht Vergessen',
          body: 'Morgen ist der Abholungstag für ${event.title}',
          scheduledDate: scheduledDate,
          payload: event.id
              .toString(), // Add event ID as payload for navigation
        );
      }
    }
  }

  Future<void> scheduleNotificationForAnEvents(
    Event event,
    TimeOfDay notificationTime,
  ) async {
    // Clear existing notifications before scheduling new ones
    await cancelNotification(event.id);

    //Make a plan for  event

    // Calculate the date and time for the notification (1 day before at 23:00)
    final scheduledDate = tz.TZDateTime(
      tz.local,
      event.date.year,
      event.date.month,
      event.date.day - 1,
      notificationTime.hour,
      notificationTime.minute,
      0,
    );

    // Only schedule if the date is in the future
    if (scheduledDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: event.id,
        title: 'Nicht Vergessen',
        body: 'Morgen ist der Abholungstag für ${event.title}',
        scheduledDate: scheduledDate,
        payload: event.id.toString(), // Add event ID as payload for navigation
      );
    }
  }

  // cancel a specific notification by its ID
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

String? selectedNotificationPayload;

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}
