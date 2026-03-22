// data/repositories/community_repository_impl.dart
import '../../domain/entities/community.dart';
import '../../domain/entities/explore_search_result.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_data_source.dart';
import '../models/community_model.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createCommunity({
    required String name,
    required String description,
    required String type,
    required String createdByType,
    required String logoPath,
    required int tagId,
  }) async {
    final requestModel = CreateCommunityRequestModel(
      name: name,
      description: description,
      type: type,
      createdByType: createdByType,
      logoPath: logoPath,
      tagId: tagId,
    );
    await remoteDataSource.createCommunity(requestModel);
  }

  @override
  Future<List<Community>> getCommunitiesByType(String type) async {
    final models = await remoteDataSource.getCommunitiesByType(type);
    return models.map((model) => Community(
          id: model.id,
          name: model.name,
          description: model.description,
          type: model.type,
          createdBy: model.createdBy,
          createdByType: model.createdByType,
          logoPath: model.logoPath,
          tagId: model.tagId,
          guidelinesEncourage: model.guidelinesEncourage,
          guidelinesDiscourage: model.guidelinesDiscourage,
          guidelinesDontTolerate: model.guidelinesDontTolerate,
          members: model.members,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
        )).toList();
  }

  @override
  Future<Community?> getCommunity(String createdByType) async {
    final model = await remoteDataSource.getCommunity(createdByType);
    if (model == null) return null;
    return Community(
      id: model.id,
      name: model.name,
      description: model.description,
      type: model.type,
      createdBy: model.createdBy,
      createdByType: model.createdByType,
      logoPath: model.logoPath,
      tagId: model.tagId,
      guidelinesEncourage: model.guidelinesEncourage,
      guidelinesDiscourage: model.guidelinesDiscourage,
      guidelinesDontTolerate: model.guidelinesDontTolerate,
      members: model.members,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<Community?> getCommunityById(String communityId) async {
    final model = await remoteDataSource.getCommunityById(communityId);
    if (model == null) return null;
    return Community(
      id: model.id,
      name: model.name,
      description: model.description,
      type: model.type,
      createdBy: model.createdBy,
      createdByType: model.createdByType,
      logoPath: model.logoPath,
      tagId: model.tagId,
      guidelinesEncourage: model.guidelinesEncourage,
      guidelinesDiscourage: model.guidelinesDiscourage,
      guidelinesDontTolerate: model.guidelinesDontTolerate,
      members: model.members,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<void> updateCommunity(String createdByType, Map<String, dynamic> body) async {
    await remoteDataSource.updateCommunity(createdByType, body);
  }

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    return remoteDataSource.getTags();
  }

  @override
  Future<void> followCommunity(String communityId) async {
    await remoteDataSource.followCommunity(communityId);
  }

  @override
  Future<void> unfollowCommunity(String communityId) async {
    await remoteDataSource.unfollowCommunity(communityId);
  }

  @override
  Future<ExploreSearchResult> exploreSearch(String q) async {
    return remoteDataSource.exploreSearch(q);
  }
}



