// data/repositories/comment_repository_impl.dart
import '../../domain/entities/comment.dart';
import '../../domain/entities/create_comment_request.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';
import '../models/create_comment_request_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    final comments = await remoteDataSource.getCommentsByPostId(postId);
    return comments;
  }

  @override
  Future<List<Comment>> getRepliesByCommentId(String commentId) async {
    final replies = await remoteDataSource.getRepliesByCommentId(commentId);
    return replies;
  }

  @override
  Future<void> createComment(CreateCommentRequest request) async {
    final requestModel = CreateCommentRequestModel.fromEntity(request);
    await remoteDataSource.createComment(requestModel);
  }
}
