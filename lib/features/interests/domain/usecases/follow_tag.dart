// domain/usecases/follow_tag.dart
import '../repositories/interests_repository.dart';

class FollowTag {
  final InterestsRepository repository;

  FollowTag(this.repository);

  Future<void> call(int tagId, String tagName) {
    return repository.followTag(tagId, tagName);
  }
}

