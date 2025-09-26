import 'package:dermuell/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsEnabledProvider = StateProvider<bool>((ref) => false);

final selectedNotificationTimeProvider = StateProvider<TimeOfDay>((ref) {
  return TimeOfDay(hour: 21, minute: 0); // standart Time
});
