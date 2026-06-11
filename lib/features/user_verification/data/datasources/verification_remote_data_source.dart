import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/email_verification_response_model.dart';

abstract class VerificationRemoteDataSource {
  Future<EmailVerificationResponseModel> sendEmailOtp({
    required String email,
    required String purpose,
  });

  Future<EmailVerificationResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  });

  Future<EmailVerificationResponseModel> sendPhoneOtp({
    required String phoneNumber,
    required String purpose,
  });

  Future<EmailVerificationResponseModel> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    required String purpose,
  });

  Future<EmailVerificationResponseModel> resendOtp({
    required String target,
    required String channel,
    required String purpose,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final Dio client;
  VerificationRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<EmailVerificationResponseModel> sendEmailOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      print('📧 Sending OTP to email: $email for purpose: $purpose');

      final response = await client.post(
        '/api/v1/otp/send',
        data: {
          "target": email,
          "channel": "email",
          "purpose": purpose,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('📦 Send Email OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<EmailVerificationResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      print('📧 Verifying email OTP: $email with code: $otp');

      final response = await client.post(
        '/api/v1/otp/verify',
        data: {
          "target": email,
          "channel": "email",
          "code": otp,
          "purpose": purpose,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('📦 Verify Email OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<EmailVerificationResponseModel> sendPhoneOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    try {
      print('📱 Sending OTP to phone: $phoneNumber for purpose: $purpose');

      final response = await client.post(
        '/api/v1/otp/send',
        data: {
          "target": phoneNumber,
          "channel": "sms",
          "purpose": purpose,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('📦 Send Phone OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<EmailVerificationResponseModel> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    required String purpose,
  }) async {
    try {
      print('📱 Verifying phone OTP: $phoneNumber with code: $otp');

      final response = await client.post(
        '/api/v1/otp/verify',
        data: {
          "target": phoneNumber,
          "channel": "sms",
          "code": otp,
          "purpose": purpose,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('📦 Verify Phone OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<EmailVerificationResponseModel> resendOtp({
    required String target,
    required String channel,
    required String purpose,
  }) async {
    try {
      print('🔄 Resending OTP to $target via $channel');

      final response = await client.post(
        '/api/v1/otp/resend',
        data: {
          "target": target,
          "channel": channel,
          "purpose": purpose,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('📦 Resend OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        'Connection timeout. Please check your internet connection.',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
        'No internet connection. Please check your network.',
      );
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      String errorMessage = 'An error occurred';
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('error')) {
          errorMessage = responseData['error'] as String;
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'] as String;
        }
      }

      return ServerException(errorMessage, statusCode: statusCode);
    } else {
      return NetworkException('Network error: ${e.message}');
    }
  }
}
