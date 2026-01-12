// data/repositories/post_repository_impl.dart
import '../../domain/entities/post.dart';
import '../../domain/entities/create_post_request.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/create_post_request_model.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createPost(CreatePostRequest request) async {
    final requestModel = CreatePostRequestModel(
      tagId: request.tagId,
      content: request.content,
      attachments: request.attachments
          .map((a) => AttachmentModel(type: a.type, url: a.url))
          .toList(),
      poll: request.poll != null
          ? PollModel(
              question: request.poll!.question,
              options: request.poll!.options
                  .map((o) => PollOptionModel(
                        optionId: o.optionId,
                        text: o.text,
                        votes: o.votes,
                      ))
                  .toList(),
              expiresAt: request.poll!.expiresAt,
              createdAt: request.poll!.createdAt,
            )
          : null,
    );
    await remoteDataSource.createPost(requestModel);
  }

  @override
  Future<List<Post>> getPostsByAuthorId() async {
    // Backend gets authorId from JWT token, so no parameter needed
    final posts = await remoteDataSource.getPostsByAuthorId();
    return posts;
  }

  @override
  Future<List<Post>> getPostsByCommunityId(String communityId) async {
    final posts = await remoteDataSource.getPostsByCommunityId(communityId);
    return posts;
  }

  @override
  Future<List<Post>> getPostsByTagId(int tagId) async {
    final posts = await remoteDataSource.getPostsByTagId(tagId);
    return posts;
  }

  @override
  Future<List<Post>> getPostsByIds(List<String> postIds) async {
    final posts = await remoteDataSource.getPostsByIds(postIds);
    return posts;
  }

  @override
  Future<void> deletePost(String postId) async {
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<void> likePost(String postId) async {
    await remoteDataSource.likePost(postId);
  }

  @override
  Future<void> unlikePost(String postId) async {
    await remoteDataSource.unlikePost(postId);
  }

  @override
  Future<void> bookmarkPost(String postId) async {
    await remoteDataSource.bookmarkPost(postId);
  }

  @override
  Future<void> unbookmarkPost(String postId) async {
    await remoteDataSource.unbookmarkPost(postId);
  }
}



