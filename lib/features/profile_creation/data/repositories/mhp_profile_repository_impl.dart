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
}

