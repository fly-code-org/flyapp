// domain/repositories/verification_repository.dart
import '../entities/email_verification_response.dart';

abstract class VerificationRepository {
  Future<EmailVerificationResponse> verifyEmail({
    required String email,
    required String otp,
  });

  Future<EmailVerificationResponse> verifyPhone({
    required String phoneNumber,
    required String otp,
  });
}

