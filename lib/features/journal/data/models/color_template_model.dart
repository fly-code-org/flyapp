// data/models/color_template_model.dart
import '../../domain/entities/journal.dart';

class ColorTemplateModel extends ColorTemplate {
  ColorTemplateModel({
    required super.id,
    required super.hexCode,
    super.moodSuggestion,
    super.label,
    super.emoji,
    super.description,
  });

  factory ColorTemplateModel.fromJson(Map<String, dynamic> json) {
    // Handle _id - can be empty string, null, or a valid ID
    final id = json['_id'];
    final idString = (id == null || id.toString().isEmpty) ? '' : id.toString();
    
    // Ensure hex_code has # prefix if present
    String hexCode = json['hex_code']?.toString() ?? '';
    if (hexCode.isNotEmpty && !hexCode.startsWith('#')) {
      hexCode = '#$hexCode';
    }
    
    return ColorTemplateModel(
      id: idString,
      hexCode: hexCode,
      moodSuggestion: json['mood_suggestion']?.toString(),
      label: json['label']?.toString(),
      emoji: json['emoji']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hex_code': hexCode,
      if (moodSuggestion != null) 'mood_suggestion': moodSuggestion,
      if (label != null) 'label': label,
      if (emoji != null) 'emoji': emoji,
      if (description != null) 'description': description,
    };
  }

  // Helper to convert hex code to Color
  int get colorValue {
    try {
      return int.parse(hexCode.replaceFirst('#', ''), radix: 16) + 0xFF000000;
    } catch (e) {
      return 0xFFFFFFFF; // Default to white
    }
  }
}

