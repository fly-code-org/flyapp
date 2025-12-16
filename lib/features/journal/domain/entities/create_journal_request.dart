// domain/entities/create_journal_request.dart
class CreateJournalRequest {
  final String title;
  final String content;
  final String? colorTemplateId;
  final String? mood;
  final List<String> tags;

  CreateJournalRequest({
    required this.title,
    required this.content,
    this.colorTemplateId,
    this.mood,
    this.tags = const [],
  });
}

