// domain/repositories/journal_repository.dart
import '../entities/journal.dart';
import '../entities/create_journal_request.dart';

import '../entities/update_journal_request.dart';

abstract class JournalRepository {
  Future<List<Journal>> getJournals({int limit = 10, int skip = 0});
  Future<Journal> createJournal(CreateJournalRequest request);
  Future<Journal> updateJournal(int journalId, UpdateJournalRequest request);
  Future<List<ColorTemplate>> getColorTemplates({int limit = 100, int skip = 0});
  Future<ColorTemplate> createColorTemplate({
    required String hexCode,
    String? moodSuggestion,
    String? label,
    String? emoji,
    String? description,
  });
}

