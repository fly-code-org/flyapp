// domain/repositories/user_profile_repository.dart
import '../entities/user_profile_response.dart';

abstract class UserProfileRepository {
  Future<UserProfileResponse> createProfile({
    required Map<String, dynamic> profileData,
  });
  Future<Map<String, dynamic>> getUserProfile();
}

