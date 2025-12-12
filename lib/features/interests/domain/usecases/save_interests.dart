// domain/usecases/save_interests.dart
import '../entities/interests.dart';
import '../repositories/interests_repository.dart';

class SaveInterests {
  final InterestsRepository repository;

  SaveInterests(this.repository);

  Future<void> call(Interests interests) {
    return repository.saveInterests(interests);
  }
}

