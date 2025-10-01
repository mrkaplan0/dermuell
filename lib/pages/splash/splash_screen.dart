import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: constraints.maxHeight - (constraints.maxHeight / 2) - 75,
                child: Image.asset(
                  "assets/images/muell.png",
                  width: 50,
                  height: 50,
                ),
              ).animate().moveY(
                delay: 600.ms,
                duration: 1000.ms,
                begin: -400,
                end: 50,
                curve: Curves.easeOut,
              ),
              Positioned(
                top: constraints.maxHeight - (constraints.maxHeight / 2) - 220,
                right: constraints.maxWidth / 2 - 100,
                child: Image.asset(
                  "assets/images/cover2.png",
                  width: 150,
                  height: 150,
                ),
              ).animate(
                effects: [
                  MoveEffect(
                    delay: 1800.ms,
                    duration: 900.ms,
                    begin: Offset(60, 5),
                    end: Offset(-53, -27),
                    curve: Curves.easeOut,
                  ),
                  RotateEffect(
                    delay: 1500.ms,
                    duration: 950.ms,
                    curve: Curves.easeIn,
                    begin: 0.0, // 90 degree
                    end: -0.25, // Closed position
                  ),
                ],
                onComplete: (controller) =>
                    Navigator.of(context).pushReplacementNamed('/landing'),
              ),
              Positioned(
                top: constraints.maxHeight - (constraints.maxHeight / 2) - 75,
                child: Image.asset(
                  "assets/images/trashbin.png",
                  width: 150,
                  height: 150,
                ),
              ),
              Positioned(
                top: constraints.maxHeight - (constraints.maxHeight / 2) + 100,
                child: Text(
                  'Der Müll'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FingerPaint',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
