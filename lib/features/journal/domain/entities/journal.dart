// domain/entities/journal.dart
class Journal {
  final int id;
  final String userId;
  final String title;
  final String content;
  final String? colorTemplate;
  final String? mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Journal({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.colorTemplate,
    this.mood,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ColorTemplate {
  final String id;
  final String hexCode;
  final String? moodSuggestion;
  final String? label;
  final String? emoji;
  final String? description;

  ColorTemplate({
    required this.id,
    required this.hexCode,
    this.moodSuggestion,
    this.label,
    this.emoji,
    this.description,
  });
}

