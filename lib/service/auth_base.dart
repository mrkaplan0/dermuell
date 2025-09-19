import 'package:dermuell/model/user.dart';

abstract class AuthBase {
  Future<(bool, String? error)> register(
    String name,
    String email,
    String password,
    String role,
  );
  Future<(User?, String? error)> login(String email, String password);
  Future<bool> logout();
  Future<User?> currentUser(String token);
}
