// domain/usecases/update_journal.dart
import '../entities/journal.dart';
import '../entities/update_journal_request.dart';
import '../repositories/journal_repository.dart';

class UpdateJournal {
  final JournalRepository repository;

  UpdateJournal(this.repository);

  Future<Journal> call(int journalId, UpdateJournalRequest request) async {
    return await repository.updateJournal(journalId, request);
  }
}

