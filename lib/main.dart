import 'package:dermuell/const/constants.dart';
import 'package:dermuell/pages/auth/login_page.dart';
import 'package:dermuell/pages/home_page.dart';
import 'package:dermuell/pages/landing_page.dart';
import 'package:dermuell/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await initializeDateFormatting('de_DE', null);
  await Hive.initFlutter();
  await Hive.openBox('dataBox');

  runApp(ProviderScope(child: const MyApp()));
}

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Der Müll',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: XConst.bgColor,
        colorScheme: ColorScheme.fromSeed(seedColor: XConst.fifthColor),
      ),
    );
  }
}
