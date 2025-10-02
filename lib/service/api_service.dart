import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;
  String? _token;

  ApiService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 5),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    _token = token;
    print(_token);
    await _storage.write(key: 'token', value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'token');
    _dio.options.headers.remove('Authorization');
  }

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: 'token');
    return _token;
  }
}
