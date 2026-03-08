// domain/repositories/mhp_profile_repository.dart
import '../entities/mhp_profile_response.dart';

abstract class MhpProfileRepository {
  Future<MhpProfileResponse> createProfile({
    required Map<String, dynamic> profileData,
  });
  Future<Map<String, dynamic>> getMhpProfile();
  Future<Map<String, dynamic>> getAboutMe();
  Future<void> updateAboutMe(Map<String, dynamic> body);
  Future<void> updateConnect(Map<String, dynamic> body);
}

