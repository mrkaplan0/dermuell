import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;
  String? _token;
  bool _isRefreshing = false;

  ApiService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5), // Daha kısa timeout
        receiveTimeout: const Duration(seconds: 10), // Daha kısa timeout
        sendTimeout: const Duration(seconds: 5), // Send timeout da ekleyelim
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // Bu çok önemli: 4xx ve 5xx kodlarını exception'a çevirir
        validateStatus: (status) {
          return status != null && status < 400;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Token varsa ekle
            final token = await getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            debugPrint(
              '🚀 REQUEST[${options.method}] => PATH: ${options.path}',
            );
            debugPrint('🚀 HEADERS: ${options.headers}');
            debugPrint('🚀 DATA: ${options.data}');
            return handler.next(options);
          } catch (e) {
            debugPrint('❌ REQUEST INTERCEPTOR ERROR: $e');
            return handler.next(options);
          }
        },
        onResponse: (response, handler) {
          try {
            debugPrint(
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );

            debugPrint('✅ RESPONSE DATA: ${response.data}');
            return handler.next(response);
          } catch (e) {
            return handler.next(response);
          }
        },
        onError: (DioException e, handler) async {
          try {
            debugPrint(
              '❌ ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            );
            if (e.response?.statusCode == 401 && !_isRefreshing) {
              debugPrint('🔄 Token refresh initiated for 401 error');
              _isRefreshing = true;
              try {
                await clearToken();
                debugPrint('🗑️ Token cleared due to 401 error');
              } catch (clearError) {
                debugPrint('❌ Error clearing token: $clearError');
              } finally {
                _isRefreshing = false;
                debugPrint('🔄 Token refresh process completed');
              }
            }

            return handler.next(e);
          } catch (interceptorError) {
            debugPrint('❌ ERROR INTERCEPTOR INTERNAL ERROR: $interceptorError');
            return handler.next(e);
          }
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    _token = token;
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
