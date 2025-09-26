import 'package:dermuell/service/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsEnabledProvider = StateProvider<bool>((ref) => false);
