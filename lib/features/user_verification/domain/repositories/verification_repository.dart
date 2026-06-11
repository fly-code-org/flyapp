import '../entities/email_verification_response.dart';

abstract class VerificationRepository {
  Future<EmailVerificationResponse> sendEmailOtp({
    required String email,
    required String purpose,
  });

  Future<EmailVerificationResponse> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  });

  Future<EmailVerificationResponse> sendPhoneOtp({
    required String phoneNumber,
    required String purpose,
  });

  Future<EmailVerificationResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    required String purpose,
  });

  Future<EmailVerificationResponse> resendOtp({
    required String target,
    required String channel,
    required String purpose,
  });
}
