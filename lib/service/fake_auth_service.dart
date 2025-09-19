import 'package:dermuell/model/user.dart';
import 'package:dermuell/service/auth_base.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeAuthService implements AuthBase {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  @override
  Future<User?> currentUser(String token) {
    return Future.value(
      User(
        id: 1,
        name: 'Test User',
        email: 'test@test.com',
        password: "password",
        role: 'user',
      ),
    );
  }

  @override
  Future<(User?, String?)> login(String email, String password) {
    if (email != 'test@test.com' || password != 'password') {
      return Future.value((null, 'Invalid email or password'));
    }
    _storage.write(key: 'token', value: "fake_token_123");
    return Future.value((
      User(id: 1, name: 'Test User', email: 'test@test.com', role: "user"),
      null,
    ));
  }

  @override
  Future<bool> logout() {
    _storage.delete(key: 'token');
    return Future.value(true);
  }

  @override
  Future<(bool, String?)> register(
    String name,
    String email,
    String password,
    String role,
  ) {
    return Future.value((true, null));
  }
}
