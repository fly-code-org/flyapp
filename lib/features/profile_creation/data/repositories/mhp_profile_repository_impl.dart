// data/repositories/mhp_profile_repository_impl.dart
import '../../domain/entities/mhp_profile_response.dart';
import '../../domain/repositories/mhp_profile_repository.dart';
import '../datasources/mhp_profile_remote_data_source.dart';

class MhpProfileRepositoryImpl implements MhpProfileRepository {
  final MhpProfileRemoteDataSource remoteDataSource;
  MhpProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<MhpProfileResponse> createProfile({
    required Map<String, dynamic> profileData,
  }) async {
    final response = await remoteDataSource.createProfile(
      profileData: profileData,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getMhpProfile() async {
    return remoteDataSource.getMhpProfile();
  }

  @override
  Future<Map<String, dynamic>> getMhpProfileByUserId(String userId) async {
    return remoteDataSource.getMhpProfileByUserId(userId);
  }

  @override
  Future<Map<String, dynamic>> getBookedSessions({
    int skip = 0,
    int limit = 20,
  }) async {
    return remoteDataSource.getBookedSessions(skip: skip, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getAboutMe() async {
    return remoteDataSource.getAboutMe();
  }

  @override
  Future<void> updateAboutMe(Map<String, dynamic> body) async {
    return remoteDataSource.updateAboutMe(body);
  }

  @override
  Future<void> updateConnect(Map<String, dynamic> body) async {
    return remoteDataSource.updateConnect(body);
  }
}

