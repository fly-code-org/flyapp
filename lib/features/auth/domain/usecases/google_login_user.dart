// domain/usecases/google_login_user.dart
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUser {
  final AuthRepository repository;

  GoogleLoginUser(this.repository);

  Future<AuthResponse> call({
    required String accessToken,
    required String role,
    String? currentPlatform,
  }) {
    return repository.googleLogin(
      accessToken: accessToken,
      role: role,
      currentPlatform: currentPlatform,
    );
  }
}

