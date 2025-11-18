// domain/usecases/signup_user.dart
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<AuthResponse> call({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  }) {
    return repository.signup(
      userName: userName,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
    );
  }
}
