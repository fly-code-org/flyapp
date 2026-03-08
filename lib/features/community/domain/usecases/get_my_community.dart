import '../entities/community.dart';
import '../repositories/community_repository.dart';

/// Fetches the current MHP's community (created at signup). Returns null if none.
class GetMyCommunity {
  final CommunityRepository repository;

  GetMyCommunity(this.repository);

  Future<Community?> call() => repository.getCommunity('mhp');
}
