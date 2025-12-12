// domain/repositories/interests_repository.dart
import '../entities/interests.dart';

abstract class InterestsRepository {
  Future<void> saveInterests(Interests interests);
}

