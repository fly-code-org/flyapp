// data/datasources/auth_remote_data_sources.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> signup({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> googleLogin({
    required String accessToken,
    required String role,
    String? currentPlatform,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  AuthRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<AuthResponseModel> signup({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  }) async {
    try {
      final response = await client.post(
        '/users/external/v1/signup',
        data: {
          "user_name": userName,
          "first_name": firstName,
          "last_name": lastName,
          "password": password,
          "phone_number": phoneNumber,
          "email": email,
          "role": role,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        // Handle API error responses
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Parse error message from response
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              // Check for "err" key
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
              // Check for "err: " key (with colon and space - signup API format)
              else if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              }
              // Check for any key starting with "err"
              else {
                for (final key in msgMap.keys) {
                  if (key.toString().trim().startsWith('err')) {
                    errorMessage = msgMap[key] as String;
                    break;
                  }
                }
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'] as String;
          }
        }

        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions (like from AuthResponseModel.fromJson)
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        '/users/external/v1/login',
        data: {"email": email, "password": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Debug: Log the actual response
        print('📦 Login API Response:');
        print('   Status Code: ${response.statusCode}');
        print('   Response Data: ${response.data}');
        print('   Response Type: ${response.data.runtimeType}');

        // Ensure response.data is a Map
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}. Response: ${response.data}',
          );
        }

        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        // Handle API error responses
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        // Parse error message from response
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              // Check for "err" key
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
              // Check for "err: " key (with colon and space - signup API format)
              else if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              }
              // Check for any key starting with "err"
              else {
                for (final key in msgMap.keys) {
                  if (key.toString().trim().startsWith('err')) {
                    errorMessage = msgMap[key] as String;
                    break;
                  }
                }
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'] as String;
          }
        }

        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions (like from AuthResponseModel.fromJson)
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> googleLogin({
    required String accessToken,
    required String role,
    String? currentPlatform,
  }) async {
    try {
      print('🔐 Starting Google login API call');
      print(
        '🎫 Access Token: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
      );
      print('👤 Role: $role');
      print('📱 Platform: ${currentPlatform ?? 'web'}');

      final response = await client.get(
        '/users/external/v1/google-login/',
        queryParameters: {
          'access_token': accessToken,
          'role': role,
          'current_platform': currentPlatform ?? 'web',
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 Google Login API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}. Response: ${response.data}',
          );
        }

        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in Google login: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            errorMessage = responseData['error'] as String;
          } else if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              } else if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              } else {
                for (final key in msgMap.keys) {
                  if (key.toString().trim().startsWith('err')) {
                    errorMessage = msgMap[key] as String;
                    break;
                  }
                }
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          }
        }

        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
