// data/models/journal_model.dart
import '../../domain/entities/journal.dart';

class JournalModel extends Journal {
  JournalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    super.colorTemplate,
    super.mood,
    required super.tags,
    required super.createdAt,
    required super.updatedAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      // Map from color_template_id (database field) to colorTemplate (entity field)
      colorTemplate: json['color_template_id']?.toString() ?? json['color_template']?.toString(),
      mood: json['mood']?.toString(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (colorTemplate != null) 'color_template_id': colorTemplate,
      if (mood != null) 'mood': mood,
      'tags': tags,
    };
  }
}

