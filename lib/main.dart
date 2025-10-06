import 'dart:async';
import 'dart:io';

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/event.dart';
import 'package:dermuell/pages/address/select_address_page.dart';
import 'package:dermuell/pages/auth/login_page.dart';
import 'package:dermuell/pages/details/notification_detail_page.dart';
import 'package:dermuell/pages/nav_pages/waste_management_page.dart';
import 'package:dermuell/pages/landing_page.dart';
import 'package:dermuell/pages/splash/splash_screen.dart';
import 'package:dermuell/service/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:easy_localization/easy_localization.dart';

void onDidReceiveNotificationResponse(NotificationResponse details) {
  final String? payload = details.payload;
  if (payload != null) {
    debugPrint('notification payload: $payload');
    // Payload'u kullanarak yönlendirme yap
    // Örneğin, payload etkinliğin ID'sini içeriyorsa:
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => NotificationDetailPage(payload)),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService().init();
  await initializeDateFormatting('de_DE', null);
  await Hive.initFlutter();

  // Register the Event adapter
  Hive.registerAdapter(EventAdapter());

  await Hive.openBox('dataBox');

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
      child: ProviderScope(child: MyApp()),
    ),
  );
}

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: unused_field
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureSelectNotificationSubject();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
      if (mounted) {
        setState(() {
          _notificationsEnabled = granted;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission = await androidImplementation
          ?.requestNotificationsPermission();
      if (mounted) {
        setState(() {
          _notificationsEnabled = grantedNotificationPermission ?? false;
        });
      }
    }
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((
      NotificationResponse? response,
    ) async {
      await rootNavigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              NotificationDetailPage(response?.payload),
        ),
      );
    });
  }

  @override
  void dispose() {
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Der Müll'.tr(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => LandingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const WasteManagement(),
        '/address': (context) => const SelectAddressPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: XConst.bgColor,
        colorScheme: ColorScheme.fromSeed(seedColor: XConst.fifthColor),
      ),
    );
  }
}
