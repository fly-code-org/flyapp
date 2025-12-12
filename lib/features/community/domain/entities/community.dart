// domain/entities/community.dart
import 'package:equatable/equatable.dart';

class Community extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // "social" or "support"
  final String createdBy;
  final String createdByType; // "user" or "mhp"
  final String logoPath;
  final int tagId;
  final List<String>? members;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.createdByType,
    required this.logoPath,
    required this.tagId,
    this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        createdBy,
        createdByType,
        logoPath,
        tagId,
        members,
        createdAt,
        updatedAt,
      ];
}

