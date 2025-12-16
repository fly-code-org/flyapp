// domain/entities/update_journal_request.dart
class UpdateJournalRequest {
  final String? title;
  final String? content;
  final String? colorTemplateId;
  final String? mood;
  final List<String> tags;

  UpdateJournalRequest({
    this.title,
    this.content,
    this.colorTemplateId,
    this.mood,
    this.tags = const [],
  });
}

