// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/main.dart';
import 'package:dermuell/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  late String _email, _username;
  String _verifyPasswort = '';
  String _password = '';
  final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  final String _invalidPassword =
      "Das Passwort muss mindestens 6 Zeichen lang sein";
  final String _passwordLabelText = 'Passwort';
  final String _password2LabelText = 'Passwort Wiederholung';
  final String _wrongPassword = "Passwörter stimmen nicht überein.";
  final String invalidEmailPrompt =
      'Bitte eine gültige E-Mail-Adresse eingeben';

  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width > 600 ? 300 : 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Registrieren', style: XConst.myBigTitleTextStyle),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Benutzername',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                ),
                validator: (value) {
                  _username = value!;
                  return value.isEmpty
                      ? 'Bitte einen Benutzernamen eingeben'
                      : null;
                },
                onSaved: (String? value) {
                  _username = value!;
                },
                keyboardType: TextInputType.text,
              ),

              TextFormField(
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
                  _email = v;

                  if (v.isEmpty) {
                    return invalidEmailPrompt;
                  }
                  if (!_emailRegex.hasMatch(v)) {
                    return invalidEmailPrompt;
                  }
                  return null;
                },

                onSaved: (String? value) {
                  _email = value!;
                },

                keyboardType: TextInputType.emailAddress,
              ),

              passwordFormfield(context),
              passwordFormfield2(context),

              ElevatedButton(
                onPressed: () {
                  _register(context, ref);
                },
                child: const Text('Registrieren'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Haben Sie schon ein Konto?"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField passwordFormfield(BuildContext context) {
    return TextFormField(
      initialValue: "password",
      focusNode: focusNode,
      obscureText: true,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        ),
        labelText: _passwordLabelText,

        suffixIcon: const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Icon(Icons.lock_outline_rounded),
        ),
      ),
      validator: (value) {
        final v = (value ?? '').trim();
        _password = v;
        return v.length < 6 ? _invalidPassword : null;
      },
      onFieldSubmitted: (value) {
        focusNode.unfocus();
      },
      onSaved: (String? gelenSifre) {
        _password = (gelenSifre ?? '').trim();
      },
    );
  }

  TextFormField passwordFormfield2(BuildContext context) {
    return TextFormField(
      initialValue: "password",
      focusNode: focusNode2,
      obscureText: true,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        ),
        labelText: _password2LabelText,

        suffixIcon: const Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Icon(Icons.lock_outline_rounded),
        ),
      ),
      validator: (value) {
        final confirm = (value ?? '').trim();
        _verifyPasswort = confirm;
        final original = _password.trim();
        if (confirm.length < 6) {
          return _invalidPassword;
        } else if (original.isNotEmpty && original != confirm) {
          return _wrongPassword;
        } else {
          return null;
        }
      },
      onFieldSubmitted: (value) {
        focusNode2.unfocus();
      },
      onSaved: (String? gelenSifre) {
        _verifyPasswort = (gelenSifre ?? '').trim();
      },
    );
  }

  Future _register(BuildContext context, WidgetRef ref) async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState?.save();
        debugPrint('$_username, $_email, $_password, $_verifyPasswort');
        var authService = ref.read(authServiceProvider);

        var (result, error) = await authService.register(
          _username,
          _email,
          _password,
          'user',
        );

        if (error != null) {
          _showErrorDialog(context, 'Registration failed. Please try again.');
          return;
        }
        if (result) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Super! Jezt anmelden!')));
          // Navigate to home or another page after successful registration
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      // String errorMessage = _getErrorMessage(e);

      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text("Error!"),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Abbrechen"),
            ),
          ],
        );
      },
    );
  }
}
