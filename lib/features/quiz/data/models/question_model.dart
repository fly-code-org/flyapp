import '../../domain/entities/question.dart';
import 'question_option_model.dart';

class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.question,
    required super.tags,
    required super.category,
    required super.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    print('🔍 [QUESTION MODEL] Parsing from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Options count: ${(json['options'] as List?)?.length ?? 0}');
    
    // Try uppercase ID first, then lowercase id
    final questionId = json['ID']?.toString() ?? json['id']?.toString() ?? '';
    
    print('   Parsed Question ID: "$questionId"');
    
    final options = (json['options'] as List<dynamic>?)
            ?.map((opt) {
              print('   📋 Parsing option: $opt');
              return QuestionOptionModel.fromJson(opt as Map<String, dynamic>);
            })
            .toList() ??
        [];
    
    print('   ✅ Parsed ${options.length} options');
    
    return QuestionModel(
      id: questionId,
      question: json['question'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      options: options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'tags': tags,
      'category': category,
      'options': options.map((opt) => (opt as QuestionOptionModel).toJson()).toList(),
    };
  }
}

