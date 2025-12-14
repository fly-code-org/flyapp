// domain/usecases/unfollow_tag.dart
import '../repositories/interests_repository.dart';

class UnfollowTag {
  final InterestsRepository repository;

  UnfollowTag(this.repository);

  Future<void> call(int tagId) {
    return repository.unfollowTag(tagId);
  }
}

