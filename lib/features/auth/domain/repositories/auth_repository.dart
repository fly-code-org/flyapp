// domain/repositories/auth_repository.dart
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> signup({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  });

  Future<AuthResponse> login({required String email, required String password});

  Future<AuthResponse> googleLogin({
    required String accessToken,
    required String role,
    String? currentPlatform,
  });
}
