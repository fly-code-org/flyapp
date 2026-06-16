import '../repositories/post_repository.dart';

class ReportPost {
  final PostRepository repository;
  ReportPost(this.repository);

  Future<void> call(String postId, String reason) async {
    return await repository.reportPost(postId, reason);
  }
}
