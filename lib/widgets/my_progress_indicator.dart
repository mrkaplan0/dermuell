import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset("assets/images/muell.png", width: 50, height: 50)
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 1000.ms),
    );
  }
}
