// domain/usecases/verify_phone.dart
import '../entities/email_verification_response.dart';
import '../repositories/verification_repository.dart';

class VerifyPhone {
  final VerificationRepository repository;

  VerifyPhone(this.repository);

  Future<EmailVerificationResponse> call({
    required String phoneNumber,
    required String otp,
  }) {
    return repository.verifyPhone(
      phoneNumber: phoneNumber,
      otp: otp,
    );
  }
}

