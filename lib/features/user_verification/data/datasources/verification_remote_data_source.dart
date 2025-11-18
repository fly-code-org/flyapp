// data/datasources/verification_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/email_verification_response_model.dart';

abstract class VerificationRemoteDataSource {
  Future<EmailVerificationResponseModel> verifyEmail({
    required String email,
    required String otp,
  });

  Future<EmailVerificationResponseModel> verifyPhone({
    required String phoneNumber,
    required String otp,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final Dio client;
  VerificationRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<EmailVerificationResponseModel> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      print('📧 Verifying email: $email with OTP: $otp');
      
      final response = await client.patch(
        '/users/external/v1/email-verify-otp',
        data: {
          "email": email,
          "otp": otp,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      // Debug: Log the actual response
      print('📦 Email Verification API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Type: ${response.data.runtimeType}');

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure response.data is a Map
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}. Response: ${response.data}',
          );
        }

        return EmailVerificationResponseModel.fromJson(
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
          if (responseData.containsKey('error') && responseData['error'] is String) {
            errorMessage = responseData['error'] as String;
          } else if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              // Check for "err" key
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
              // Check for "err: " key (with colon and space)
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
          }
        }

        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions (like from EmailVerificationResponseModel.fromJson)
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<EmailVerificationResponseModel> verifyPhone({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      print('📱 Verifying phone: $phoneNumber with OTP: $otp');

      final response = await client.patch(
        '/users/external/v1/phone-verify-otp',
        data: {
          "phone_number": phoneNumber,
          "otp": otp,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      // Debug: Log the actual response
      print('📦 Phone Verification API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Type: ${response.data.runtimeType}');

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure response.data is a Map
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}. Response: ${response.data}',
          );
        }

        return EmailVerificationResponseModel.fromJson(
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
          if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            errorMessage = responseData['error'] as String;
          } else if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              // Check for "err" key
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
              // Check for "err: " key (with colon and space)
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
          }
        }

        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle other exceptions (like from EmailVerificationResponseModel.fromJson)
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}

