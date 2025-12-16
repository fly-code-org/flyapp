// domain/usecases/create_journal.dart
import '../entities/journal.dart';
import '../entities/create_journal_request.dart';
import '../repositories/journal_repository.dart';

class CreateJournal {
  final JournalRepository repository;

  CreateJournal(this.repository);

  Future<Journal> call(CreateJournalRequest request) async {
    return await repository.createJournal(request);
  }
}

