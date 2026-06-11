import '../../domain/entities/email_verification_response.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  VerificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<EmailVerificationResponse> sendEmailOtp({
    required String email,
    required String purpose,
  }) async {
    final response = await remoteDataSource.sendEmailOtp(
      email: email,
      purpose: purpose,
    );
    return response;
  }

  @override
  Future<EmailVerificationResponse> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    final response = await remoteDataSource.verifyEmailOtp(
      email: email,
      otp: otp,
      purpose: purpose,
    );
    return response;
  }

  @override
  Future<EmailVerificationResponse> sendPhoneOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    final response = await remoteDataSource.sendPhoneOtp(
      phoneNumber: phoneNumber,
      purpose: purpose,
    );
    return response;
  }

  @override
  Future<EmailVerificationResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    required String purpose,
  }) async {
    final response = await remoteDataSource.verifyPhoneOtp(
      phoneNumber: phoneNumber,
      otp: otp,
      purpose: purpose,
    );
    return response;
  }

  @override
  Future<EmailVerificationResponse> resendOtp({
    required String target,
    required String channel,
    required String purpose,
  }) async {
    final response = await remoteDataSource.resendOtp(
      target: target,
      channel: channel,
      purpose: purpose,
    );
    return response;
  }
}
