import 'package:dermuell/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                top: 50,
                left: (constraints.maxWidth / 2) - 50,
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 100,
                  height: 100,
                ),
              ),

              Positioned(
                top: 170,
                left: 8,
                right: 8,
                bottom: 8,
                child: RegisterForm(),
              ),
            ],
          );
        },
      ),
    );
  }
}
