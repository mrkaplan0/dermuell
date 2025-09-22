import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BinWithEyes extends StatelessWidget {
  const BinWithEyes({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: size * 0.46,
            child: SizedBox(
              width: size * 0.85,
              height: size * 0.3,
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    right: 20,
                    child: Image.asset(
                      "assets/images/eyes1.png",
                      width: size * 0.4,
                      height: size * 0.3,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    child:
                        Image.asset(
                              "assets/images/eyelids.png",
                              width: size * 0.39,
                              height: size * 0.29,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              begin: Offset(1, -1),
                              end: Offset(1, 1),
                              duration: 600.ms,
                            )
                            .slide(
                              begin: Offset(0, -1),
                              end: Offset(0, 0),
                              duration: 600.ms,
                            )
                            .scale(
                              delay: 800.ms,
                              begin: Offset(1, 1),
                              end: Offset(1, -0.65),
                              duration: 1000.ms,
                            )
                            .slide(
                              delay: 800.ms,
                              begin: Offset(0, 0),
                              end: Offset(0, -0.7),
                              duration: 1000.ms,
                            )
                            .then(delay: 2000.ms)
                            .shake(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.5 + size * 0.22,
            child: SizedBox(
              height: size * 0.2,
              width: size * 0.6,
              child: Image.asset(
                "assets/images/cover3.png",
                width: size * 0.5,
                height: size * 0.3,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              height: size * 0.5,
              child: Image.asset(
                "assets/images/trashbin.png",
                width: size * 0.6,
                height: size * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
