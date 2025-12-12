// data/models/community_model.dart
import '../../domain/entities/community.dart';

class CommunityModel extends Community {
  CommunityModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.createdBy,
    required super.createdByType,
    required super.logoPath,
    required super.tagId,
    super.members,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    // Handle UUID fields - backend may return as string or binary
    String parseId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    // Handle datetime fields
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is Map && value.containsKey('\$date')) {
        return DateTime.parse(value['\$date']);
      }
      return DateTime.now();
    }

    // Handle members array (list of UUIDs)
    List<String>? parseMembers(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => parseId(e)).toList();
      }
      return null;
    }

    // Try uppercase ID first, then lowercase id, then _id
    final id = parseId(json['ID'] ?? json['id'] ?? json['_id'] ?? '');
    final createdBy = parseId(json['created_by'] ?? '');
    final createdByType = json['created_by_type']?.toString() ?? '';
    final logoPath = json['logo_path']?.toString() ?? '';
    final tagId = json['tag_id'] is int
        ? json['tag_id'] as int
        : int.tryParse(json['tag_id']?.toString() ?? '0') ?? 0;

    return CommunityModel(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdBy: createdBy,
      createdByType: createdByType,
      logoPath: logoPath,
      tagId: tagId,
      members: parseMembers(json['members']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'created_by': createdBy,
      'created_by_type': createdByType,
      'logo_path': logoPath,
      'tag_id': tagId,
      'members': members,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateCommunityRequestModel {
  final String name;
  final String description;
  final String type; // "social" or "support"
  final String createdByType; // "user" or "mhp"
  final String logoPath;
  final int tagId;

  CreateCommunityRequestModel({
    required this.name,
    required this.description,
    required this.type,
    required this.createdByType,
    required this.logoPath,
    required this.tagId,
  });

  factory CreateCommunityRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateCommunityRequestModel(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdByType: json['created_by_type']?.toString() ?? '',
      logoPath: json['logo_path']?.toString() ?? '',
      tagId: json['tag_id'] is int
          ? json['tag_id'] as int
          : int.tryParse(json['tag_id']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'created_by_type': createdByType,
      'logo_path': logoPath,
      'tag_id': tagId,
    };
  }
}

class CommunitiesResponseModel {
  final String msg;
  final List<CommunityModel> data;

  CommunitiesResponseModel({
    required this.msg,
    required this.data,
  });

  factory CommunitiesResponseModel.fromJson(Map<String, dynamic> json) {
    List<CommunityModel> communities = [];
    if (json.containsKey('data') && json['data'] is List) {
      final dataList = json['data'] as List;
      communities = dataList
          .map((item) => CommunityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return CommunitiesResponseModel(
      msg: json['msg']?.toString() ?? '',
      data: communities,
    );
  }
}

class CreateCommunityResponseModel {
  final String msg;
  final String? data;

  CreateCommunityResponseModel({
    required this.msg,
    this.data,
  });

  factory CreateCommunityResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCommunityResponseModel(
      msg: json['msg']?.toString() ?? '',
      data: json['data']?.toString(),
    );
  }
}

