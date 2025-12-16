// domain/usecases/get_color_templates.dart
import '../entities/journal.dart';
import '../repositories/journal_repository.dart';

class GetColorTemplates {
  final JournalRepository repository;

  GetColorTemplates(this.repository);

  Future<List<ColorTemplate>> call({int limit = 100, int skip = 0}) async {
    return await repository.getColorTemplates(limit: limit, skip: skip);
  }
}

