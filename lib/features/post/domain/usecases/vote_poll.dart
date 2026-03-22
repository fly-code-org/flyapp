import '../../domain/repositories/post_repository.dart';

class VotePoll {
  final PostRepository repository;

  VotePoll(this.repository);

  Future<void> call(String postId, String optionId) async {
    return await repository.votePoll(postId, optionId);
  }
}
