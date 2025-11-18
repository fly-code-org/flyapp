// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static Dio? _dio;
  static String? _cachedToken;

  static Dio get dio {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl.isNotEmpty
            ? AppConfig.apiBaseUrl
            : 'https://api.flyapp.in',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          try {
            final token = await _loadTokenIfNeeded();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            final logger = Logger();
            logger.e('Error loading token: $e');
          }
          
          final logger = Logger();
          logger.d('Request: ${options.method} ${options.path}');
          logger.d('Headers: ${options.headers}');
          logger.d('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final logger = Logger();
          logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
          logger.d('Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          final logger = Logger();
          logger.e('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          logger.e('Message: ${error.message}');
          logger.e('Data: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for better debugging
    _dio!.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    return _dio!;
  }

  // Method to update auth token in headers
  static void updateAuthToken(String token) {
    _cachedToken = token;
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  // Method to clear auth token
  static void clearAuthToken() {
    _cachedToken = null;
    _dio?.options.headers.remove('Authorization');
  }

  // Method to refresh token from storage
  static Future<void> refreshToken() async {
    _cachedToken = await TokenStorage.getToken();
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      _dio?.options.headers['Authorization'] = 'Bearer $_cachedToken';
    } else {
      _dio?.options.headers.remove('Authorization');
    }
  }

  // Helper method to load token if needed
  static Future<String?> _loadTokenIfNeeded() async {
    if (_cachedToken == null) {
      _cachedToken = await TokenStorage.getToken();
    }
    return _cachedToken;
  }
}

