// domain/usecases/get_journals.dart
import '../entities/journal.dart';
import '../repositories/journal_repository.dart';

class GetJournals {
  final JournalRepository repository;

  GetJournals(this.repository);

  Future<List<Journal>> call({int limit = 10, int skip = 0}) async {
    return await repository.getJournals(limit: limit, skip: skip);
  }
}

