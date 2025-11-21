// domain/repositories/mhp_profile_repository.dart
import '../entities/mhp_profile_response.dart';

abstract class MhpProfileRepository {
  Future<MhpProfileResponse> createProfile({
    required Map<String, dynamic> profileData,
  });
}

