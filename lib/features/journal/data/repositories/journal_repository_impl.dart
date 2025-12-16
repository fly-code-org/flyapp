// data/repositories/journal_repository_impl.dart
import '../../domain/entities/journal.dart';
import '../../domain/entities/create_journal_request.dart';
import '../../domain/entities/update_journal_request.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_data_source.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteDataSource remoteDataSource;

  JournalRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Journal>> getJournals({int limit = 10, int skip = 0}) async {
    final journals = await remoteDataSource.getJournals(limit: limit, skip: skip);
    return journals;
  }

  @override
  Future<Journal> createJournal(CreateJournalRequest request) async {
    // Build request body - only include fields that have values
    final journalData = <String, dynamic>{
      'title': request.title.trim(),
      'content': request.content.trim(),
    };
    
    // Only include color_template_id if it's not null and not empty
    if (request.colorTemplateId != null && 
        request.colorTemplateId!.trim().isNotEmpty) {
      journalData['color_template_id'] = request.colorTemplateId!.trim();
    }
    
    // Only include mood if it's not null and not empty
    if (request.mood != null && request.mood!.trim().isNotEmpty) {
      journalData['mood'] = request.mood!.trim();
    }
    
    // Always include tags (ensure it's a list)
    journalData['tags'] = request.tags;
    
    print('📤 [JOURNAL REPO] Journal data to send:');
    print('  - title: "${journalData['title']}"');
    print('  - content: "${journalData['content']}"');
    print('  - color_template_id: ${journalData['color_template_id'] ?? 'null (omitted)'}');
    print('  - mood: ${journalData['mood'] ?? 'null (omitted)'}');
    print('  - tags: ${journalData['tags']}');

    final journal = await remoteDataSource.createJournal(journalData);
    return journal;
  }

  @override
  Future<Journal> updateJournal(int journalId, UpdateJournalRequest request) async {
    // Build update payload - always include at least title and content
    // Don't include updated_at - backend will set it automatically
    final journalData = <String, dynamic>{};

    // Title and content should always be provided for updates
    if (request.title != null) {
      journalData['title'] = request.title!.trim();
    }
    
    if (request.content != null) {
      journalData['content'] = request.content!.trim();
    }
    
    // Only include color_template_id if it's not null and not empty
    if (request.colorTemplateId != null && request.colorTemplateId!.trim().isNotEmpty) {
      journalData['color_template_id'] = request.colorTemplateId!.trim();
    }
    
    // Only include mood if provided and not empty
    if (request.mood != null && request.mood!.trim().isNotEmpty) {
      journalData['mood'] = request.mood!.trim();
    }
    
    // Only include tags if provided and not empty
    if (request.tags.isNotEmpty) {
      journalData['tags'] = request.tags;
    }
    
    // Ensure we have at least one field to update
    if (journalData.isEmpty) {
      throw Exception('At least one field must be provided for update');
    }
    
    print('📤 [JOURNAL REPO] Update journal data to send:');
    print('  - journalId: $journalId');
    print('  - title: ${journalData['title'] ?? 'null (omitted)'}');
    print('  - content: ${journalData['content'] ?? 'null (omitted)'}');
    print('  - color_template_id: ${journalData['color_template_id'] ?? 'null (omitted)'}');
    print('  - mood: ${journalData['mood'] ?? 'null (omitted)'}');
    print('  - tags: ${journalData['tags'] ?? 'null (omitted)'}');
    print('  - updated_at: omitted (backend will set automatically)');
    print('📤 [JOURNAL REPO] Total fields to update: ${journalData.length}');

    final journal = await remoteDataSource.updateJournal(journalId, journalData);
    return journal;
  }

  @override
  Future<List<ColorTemplate>> getColorTemplates({int limit = 100, int skip = 0}) async {
    final templates = await remoteDataSource.getColorTemplates(limit: limit, skip: skip);
    return templates;
  }

  @override
  Future<ColorTemplate> createColorTemplate({
    required String hexCode,
    String? moodSuggestion,
    String? label,
    String? emoji,
    String? description,
  }) async {
    final templateData = {
      'hex_code': hexCode,
      if (moodSuggestion != null) 'mood_suggestion': moodSuggestion,
      if (label != null) 'label': label,
      if (emoji != null) 'emoji': emoji,
      if (description != null) 'description': description,
    };

    final template = await remoteDataSource.createColorTemplate(templateData);
    return template;
  }
}

