// core/network/api_client.dart
// All backend API calls (auth, post, nira, community, journal, etc.) use this client.
// Base URL comes from AppConfig.backendApiBaseUrl (API_BASE_URL in .env or default).
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static Dio? _dio;
  static String? _cachedToken;
  static bool _isLoadingToken = false;
  static final _logger = Logger();

  /// Initialize Dio instance eagerly (call this in main before runApp)
  static Future<void> initialize() async {
    if (_dio != null) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.backendApiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Pre-load token asynchronously to avoid blocking later
    _loadTokenIfNeeded().catchError((e) {
      _logger.e('Error pre-loading token: $e');
      return null;
    });

    // Add interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available (use cached token to avoid blocking)
          try {
            final token = _cachedToken ?? await _loadTokenIfNeeded();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            _logger.e('Error loading token: $e');
          }

          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          _logger.e('Message: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for better debugging (only in debug mode)
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: false, // Disable full body logging for performance
          responseBody: false,
          error: true,
        ),
      );
    }
  }

  static Dio get dio {
    if (_dio == null) {
      // Fallback initialization if initialize() wasn't called
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.backendApiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Pre-load token asynchronously
      _loadTokenIfNeeded().catchError((e) {
        _logger.e('Error pre-loading token: $e');
        return null;
      });

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = _cachedToken ?? await _loadTokenIfNeeded();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              _logger.e('Error loading token: $e');
            }
            handler.next(options);
          },
        ),
      );
    }
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
    try {
      _cachedToken = await TokenStorage.getToken();
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        _dio?.options.headers['Authorization'] = 'Bearer $_cachedToken';
      } else {
        _dio?.options.headers.remove('Authorization');
      }
    } catch (e) {
      _logger.e('Error refreshing token: $e');
    }
  }

  // Helper method to load token if needed (with caching and prevention of concurrent calls)
  static Future<String?> _loadTokenIfNeeded() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    // Prevent concurrent token loading calls
    if (_isLoadingToken) {
      // Wait a bit for the other call to complete
      await Future.delayed(const Duration(milliseconds: 100));
      if (_cachedToken != null) {
        return _cachedToken;
      }
    }

    _isLoadingToken = true;
    try {
      _cachedToken = await TokenStorage.getToken();
      return _cachedToken;
    } catch (e) {
      _logger.e('Error loading token: $e');
      return null;
    } finally {
      _isLoadingToken = false;
    }
  }

  // Get current auth token (synchronous)
  static String? getAuthToken() {
    return _cachedToken;
  }
}
