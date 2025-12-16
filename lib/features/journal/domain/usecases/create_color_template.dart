// domain/usecases/create_color_template.dart
import '../entities/journal.dart';
import '../repositories/journal_repository.dart';

class CreateColorTemplate {
  final JournalRepository repository;

  CreateColorTemplate(this.repository);

  Future<ColorTemplate> call({
    required String hexCode,
    String? moodSuggestion,
    String? label,
    String? emoji,
    String? description,
  }) async {
    return await repository.createColorTemplate(
      hexCode: hexCode,
      moodSuggestion: moodSuggestion,
      label: label,
      emoji: emoji,
      description: description,
    );
  }
}

