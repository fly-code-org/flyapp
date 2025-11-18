// data/repositories/auth_repository_impl.dart
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_sources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthResponse> signup({
    required String userName,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String email,
    required String role,
  }) async {
    // Exceptions from data source will propagate up
    final response = await remoteDataSource.signup(
      userName: userName,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
    );
    return response;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Exceptions from data source will propagate up
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );
    return response;
  }

  @override
  Future<AuthResponse> googleLogin({
    required String accessToken,
    required String role,
    String? currentPlatform,
  }) async {
    final response = await remoteDataSource.googleLogin(
      accessToken: accessToken,
      role: role,
      currentPlatform: currentPlatform,
    );
    return response;
  }
}
