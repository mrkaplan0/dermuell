import 'package:dermuell/service/fake_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:dermuell/service/auth_service.dart';
import 'package:dermuell/model/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider((ref) => FakeAuthService());
final storageProvider = Provider((ref) => FlutterSecureStorage());

// Provider to access the token from secure storage
final tokenProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(storageProvider);
  return await storage.read(key: 'token') ?? '';
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final token = await ref.watch(tokenProvider.future);
  if (token.isEmpty) {
    debugPrint('No token found, returning null user.');
    return null;
  }

  try {
    return await authService.currentUser(token);
  } catch (e) {
    debugPrint('Error getting current user: $e');
    // If there's an error getting user, invalidate token
    ref.invalidate(tokenProvider);
    return null;
  }
});

final logoutProvider = FutureProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.logout().then((success) {
    if (success) {
      ref.invalidate(tokenProvider);
      ref.invalidate(currentUserProvider);
      return true;
    } else {
      return false;
    }
  });
});
