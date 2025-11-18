// data/repositories/verification_repository_impl.dart
import '../../domain/entities/email_verification_response.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  VerificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<EmailVerificationResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    // Exceptions from data source will propagate up
    final response = await remoteDataSource.verifyEmail(
      email: email,
      otp: otp,
    );
    return response;
  }

  @override
  Future<EmailVerificationResponse> verifyPhone({
    required String phoneNumber,
    required String otp,
  }) async {
    // Exceptions from data source will propagate up
    final response = await remoteDataSource.verifyPhone(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return response;
  }
}

