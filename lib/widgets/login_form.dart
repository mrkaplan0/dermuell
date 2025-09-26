// ignore_for_file: must_be_immutable

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/pages/auth/register_page.dart';
import 'package:dermuell/provider/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerWidget {
  LoginForm({super.key, required this.animationController});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AnimationController animationController;
  late String _password, _email;
  final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  final String _invalidPassword =
      "Das Passwort muss mindestens 6 Zeichen lang sein".tr();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width > 600 ? 300 : 20),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Anmelden'.tr(), style: XConst.myBigTitleTextStyle),

            TextFormField(
              initialValue: "test@test.com",
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Email',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Icon(Icons.mail_outline_rounded),
                ),
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) {
                  return 'Bitte eine gültige E-Mail-Adresse eingeben'.tr();
                }
                if (!_emailRegex.hasMatch(v)) {
                  return 'Bitte eine gültige E-Mail-Adresse eingeben'.tr();
                }
                return null; // valid
              },

              onSaved: (String? value) {
                _email = (value ?? '').trim();
              },

              keyboardType: TextInputType.emailAddress,
            ),

            TextFormField(
              initialValue: "password",
              focusNode: focusNode2,
              decoration: InputDecoration(
                labelText: 'Passwort'.tr(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Icon(Icons.lock_outline_rounded),
                ),
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty || v.length < 6) {
                  return _invalidPassword;
                } else {
                  return null;
                }
              },

              onSaved: (String? gelenSifre) {
                _password = (gelenSifre ?? '').trim();
              },

              obscureText: true,
            ),

            ElevatedButton(
              onPressed: () => _login(context, ref),
              child: Text('Anmelden'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text("Registrieren".tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context, WidgetRef ref) async {
    focusNode.unfocus();
    focusNode2.unfocus();
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        var authService = ref.read(authServiceProvider);
        var (user, error) = await authService.login(_email, _password);

        if (error != null || user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login fehlgeschlagen. Bitte versuchen Sie es erneut. Error: $error'
                    .tr(),
              ),
            ),
          );
          return;
        } else {
          // Start animation and show message
          animationController.forward();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Willkommen ${user.name}!'.tr()),
              duration: Durations.medium1,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bitte füllen Sie alle Felder aus'.tr())),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ein Fehler ist aufgetreten: $e'.tr())),
      );
    }
  }
}
