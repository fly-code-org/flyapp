// domain/usecases/verify_email.dart
import '../entities/email_verification_response.dart';
import '../repositories/verification_repository.dart';

class VerifyEmail {
  final VerificationRepository repository;

  VerifyEmail(this.repository);

  Future<EmailVerificationResponse> call({
    required String email,
    required String otp,
  }) {
    return repository.verifyEmail(
      email: email,
      otp: otp,
    );
  }
}

