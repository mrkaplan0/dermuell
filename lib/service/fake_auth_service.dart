import 'package:dermuell/model/user.dart';
import 'package:dermuell/service/auth_base.dart';

class FakeAuthService implements AuthBase {
  @override
  Future<User?> currentUser(String token) {
    return Future.value(
      User(
        id: 1,
        name: 'Test User',
        email: 'test@test.com',
        password: "11111111",
        role: 'user',
      ),
    );
  }

  @override
  Future<(User?, String)> login(String email, String password) {
    return Future.value((
      User(id: 1, name: 'Test User', email: 'test@test.com', role: "user"),
      "fake_token_123",
    ));
  }

  @override
  Future<bool> logout() {
    return Future.value(true);
  }

  @override
  Future<bool> register(
    String name,
    String email,
    String password,
    String role,
  ) {
    return Future.value(true);
  }
}
