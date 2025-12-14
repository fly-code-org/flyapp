// data/repositories/interests_repository_impl.dart
import '../../domain/entities/interests.dart';
import '../../domain/repositories/interests_repository.dart';
import '../datasources/interests_remote_data_source.dart';
import '../models/interests_request_model.dart';

class InterestsRepositoryImpl implements InterestsRepository {
  final InterestsRemoteDataSource remoteDataSource;

  InterestsRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> saveInterests(Interests interests) async {
    // Convert entity to model
    final requestModel = InterestsRequestModel(
      tags: interests.tags
          .map((tag) => TagModel(tagId: tag.tagId, name: tag.name))
          .toList(),
      communities: interests.communities,
    );

    // Exceptions from data source will propagate up
    await remoteDataSource.saveInterests(request: requestModel);
  }

  @override
  Future<void> followTag(int tagId, String tagName) async {
    await remoteDataSource.followTag(tagId, tagName);
  }

  @override
  Future<void> unfollowTag(int tagId) async {
    await remoteDataSource.unfollowTag(tagId);
  }
}

