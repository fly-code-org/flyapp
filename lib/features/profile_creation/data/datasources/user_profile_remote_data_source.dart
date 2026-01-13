// data/datasources/user_profile_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_response_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileResponseModel> createProfile({
    required Map<String, dynamic> profileData,
  });
  Future<Map<String, dynamic>> getUserProfile();
  Future<void> updateStreak();
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final Dio client;
  UserProfileRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<UserProfileResponseModel> createProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      print('🔐 Starting User profile creation API call');
      print('📦 Profile Data: $profileData');

      final response = await client.post(
        '/users/external/v1/profile',
        data: profileData,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 User Profile API Response:');
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

        return UserProfileResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in User profile creation: ${e.type}');
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

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('🔍 [USER PROFILE API] Fetching user profile...');

      final response = await client.get(
        '/users/external/v1/profile',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [USER PROFILE API] Response Status: ${response.statusCode}');
      print('📦 [USER PROFILE API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        
        // Extract data from response: {"msg": "...", "data": {...}}
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          return responseData['data'] as Map<String, dynamic>;
        }
        
        // If data is at root level, return it
        return responseData;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [USER PROFILE API] DioException: ${e.type}');
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
          if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              } else if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
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

  @override
  Future<void> updateStreak() async {
    try {
      print('🔥 [STREAK] Updating user streak...');

      final response = await client.patch(
        '/users/external/v1/streaks',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [STREAK] Response Status: ${response.statusCode}');
      print('📦 [STREAK] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ [STREAK] Streak updated successfully');
        return;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [STREAK] DioException: ${e.type}');
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

        String errorMessage = 'Failed to update streak';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              } else if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
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

