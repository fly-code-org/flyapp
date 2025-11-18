// domain/usecases/login_user.dart
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<AuthResponse> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
