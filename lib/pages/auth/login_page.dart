// ignore_for_file: must_be_immutable
import 'package:dermuell/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController animationController1;
  late AnimationController animationController2;
  late AnimationController animationController3;

  @override
  void initState() {
    super.initState();
    animationController1 = AnimationController(vsync: this);
    animationController2 = AnimationController(vsync: this);
    animationController3 = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    animationController1.dispose();
    animationController2.dispose();
    animationController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                top: 320,
                left: (constraints.maxWidth / 2) - 27,
                child:
                    Image.asset(
                          "assets/images/muell.png",
                          width: 50,
                          height: 50,
                        ) //MÜLL ANIMATION
                        .animate(
                          effects: [
                            ScaleEffect(
                              duration: 500.ms,
                              curve: Curves.easeOut,
                              begin: Offset(0, 0),
                              end: Offset(1, 1),
                            ),
                          ],
                          autoPlay: false,

                          onComplete: (animationController2) {
                            animationController3.forward();
                          },
                          controller: animationController2,
                        )
                        .animate(
                          effects: [
                            MoveEffect(
                              duration: 1000.ms,
                              begin: Offset(0, 0),
                              end: Offset(0, 350),
                              curve: Curves.easeOut,
                            ),
                          ],
                          autoPlay: false,
                          controller: animationController3,
                        ),
              ),
              Positioned(
                top: 150,
                left: 8,
                right: 8,
                child: LoginForm(animationController: animationController1),
              )
              //FORM ANIMATION
              .animate(
                effects: [
                  ScaleEffect(
                    delay: 1000.ms,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                    begin: Offset(1, 1),
                    end: Offset(0.0, 0.0),
                  ),
                ],
                autoPlay: false,
                onComplete: (animationController1) {
                  animationController2.forward();
                },
                controller: animationController1,
              ),
              Positioned(
                bottom: 95,
                left: (constraints.maxWidth / 2) - 60,
                child:
                    Image.asset(
                          "assets/images/cover.png",
                          width: 120,
                          height: 120,
                        )
                        //COVER ANIMATION 1 to open
                        .animate(
                          effects: [
                            MoveEffect(
                              duration: 300.ms,
                              begin: Offset(-45, -35),
                              end: Offset(0, 0),
                              curve: Curves.easeOut,
                            ),
                            RotateEffect(
                              delay: 200.ms,
                              duration: 350.ms,
                              curve: Curves.easeIn,
                              begin: .6, // 90 degree
                              end: 0.8, // Closed position
                            ),
                          ],
                          autoPlay: false,
                          controller: animationController2,
                        )
                        //COVER ANIMATION 2 to close
                        .animate(
                          effects: [
                            MoveEffect(
                              delay: 1200.ms,
                              duration: 900.ms,
                              begin: Offset(-20, -60),
                              end: Offset(-5, 10),
                              curve: Curves.easeOut,
                            ),
                            RotateEffect(
                              delay: 900.ms,
                              duration: 950.ms,
                              curve: Curves.easeIn,
                              begin: 0.2, // 90 degree
                              end: -0.05, // Closed position
                            ),
                          ],
                          autoPlay: false,
                          controller: animationController3,
                          onComplete: (controller) {
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                        ),
              ),
              Positioned(
                bottom: 20,
                left: (constraints.maxWidth / 2) - 60,
                child: Image.asset(
                  "assets/images/trashbin.png",
                  width: 120,
                  height: 120,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
