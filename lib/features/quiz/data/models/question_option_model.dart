import '../../domain/entities/question_option.dart';

class QuestionOptionModel extends QuestionOption {
  QuestionOptionModel({
    required super.id,
    required super.optionText,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    // Debug: Log the JSON structure
    print('🔍 [QUESTION OPTION] Parsing from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');
    
    // Try uppercase ID first, then lowercase id
    final optionId = json['ID']?.toString() ?? json['id']?.toString() ?? '';
    final optionText = json['option_text']?.toString() ?? json['optionText']?.toString() ?? '';
    
    print('   Parsed ID: "$optionId"');
    print('   Parsed Text: "$optionText"');
    
    if (optionId.isEmpty) {
      print('⚠️ [QUESTION OPTION] WARNING: Option ID is empty after parsing!');
    }
    
    return QuestionOptionModel(
      id: optionId,
      optionText: optionText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_text': optionText,
    };
  }
}

