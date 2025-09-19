import 'package:dermuell/configs/configs.dart';
import 'package:dermuell/model/user.dart';
import 'package:dermuell/service/api_service.dart';
import 'package:dermuell/service/auth_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthService implements AuthBase {
  final ApiService _api = ApiService();
  late final Dio _dio;

  AuthService() {
    _dio = _api.dio;
  }

  /// Register a new user and return (User, token)
  @override
  Future<(bool, String? error)> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final res = await _dio.post(
      Configs.apiBaseUrl + Configs.registerUrl,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );

    final data = res.data;
    debugPrint('Register response status: ${res.statusCode}');
    debugPrint('Register response data: $data');
    if (data is! Map<String, dynamic>) {
      return (false, ('Unexpected response format'));
    }

    if (data['status'] != 'success') {
      return (
        false,
        ('Registration failed: ${data['message'] ?? 'Unknown error'}'),
      );
    }

    return (true, null); // Registration successful
  }

  /// Login a user
  @override
  Future<(User?, String? error)> login(String email, String password) async {
    final res = await _dio.post(
      Configs.apiBaseUrl + Configs.loginUrl,
      data: {'email': email, 'password': password},
    );

    final data = res.data;

    if (data is! Map<String, dynamic>) {
      return (null, 'Unexpected response format');
    }

    // Check if login was successful
    if (data['status'] != 'success') {
      return (null, 'Login failed: ${data['message'] ?? 'Unknown error'}');
    }

    // Check if user_info is present in the response
    final userJson = data['user_info'];
    if (userJson == null || userJson is! Map<String, dynamic>) {
      return (null, 'User information missing in response');
    }

    // Check if token is present
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      return (null, 'Authentication token missing in response');
    }

    // Set the token in the API service
    await _api.setToken(token);

    return (User.fromMap(userJson), token);
  }

  /// Logout
  @override
  Future<bool> logout() async {
    _dio.options.headers['Authorization'] = 'Bearer ${await _api.getToken()}';
    var response = await _dio.post(Configs.apiBaseUrl + Configs.logoutUrl);
    if (response.statusCode == 200) {
      await _api.clearToken();
      return true;
    } else {
      debugPrint('Logout failed with status code: ${response.statusCode}');
      return false;
    }
  }

  /// Current user
  @override
  Future<User?> currentUser(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final res = await _dio.get(Configs.apiBaseUrl + Configs.currentUserUrl);
    final data = res.data as Map<String, dynamic>;
    if (data.isEmpty) {
      return null; // No user data available
    }
    return User.fromMap(data);
  }
}
