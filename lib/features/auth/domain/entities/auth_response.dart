// domain/entities/auth_response.dart
class AuthResponse {
  final String token;
  final String message;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isNewUser; // Indicates if a new user was created (for Google login)

  AuthResponse({
    required this.token,
    required this.message,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isNewUser = false,
  });
}
