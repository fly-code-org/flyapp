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
    super.guidelinesEncourage,
    super.guidelinesDiscourage,
    super.guidelinesDontTolerate,
    super.members,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle UUID fields - backend may return as string or binary
      String parseId(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        // Handle MongoDB binary UUID format
        if (value is Map && value.containsKey('\$binary')) {
          final binary = value['\$binary'];
          if (binary is Map && binary.containsKey('base64')) {
            // For now, return empty string as we can't decode binary UUID easily
            // The backend should return it as string in JSON
            return '';
          }
        }
        return value.toString();
      }

      // Handle datetime fields
      DateTime parseDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return DateTime.now();
          }
        }
        if (value is Map && value.containsKey('\$date')) {
          try {
            return DateTime.parse(value['\$date']);
          } catch (e) {
            return DateTime.now();
          }
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

    // Handle tag_id - can be int, string, or MongoDB $numberLong format
    int parseTagId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      // Handle MongoDB $numberLong format: {"$numberLong": "2"}
      if (value is Map && value.containsKey('\$numberLong')) {
        final longValue = value['\$numberLong'];
        if (longValue is String) {
          return int.tryParse(longValue) ?? 0;
        }
        if (longValue is int) {
          return longValue;
        }
      }
      return int.tryParse(value.toString()) ?? 0;
    }

    // Try uppercase ID first, then lowercase id, then _id
    final id = parseId(json['ID'] ?? json['id'] ?? json['_id'] ?? '');
    final createdBy = parseId(json['created_by'] ?? '');
    final createdByType = json['created_by_type']?.toString() ?? '';
    final logoPath = json['logo_path']?.toString() ?? '';
    final tagId = parseTagId(json['tag_id']);
    final guidelinesEncourage = json['guidelines_encourage']?.toString() ?? '';
    final guidelinesDiscourage = json['guidelines_discourage']?.toString() ?? '';
    final guidelinesDontTolerate = json['guidelines_dont_tolerate']?.toString() ?? '';

      return CommunityModel(
        id: id,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        createdBy: createdBy,
        createdByType: createdByType,
        logoPath: logoPath,
        tagId: tagId,
        guidelinesEncourage: guidelinesEncourage,
        guidelinesDiscourage: guidelinesDiscourage,
        guidelinesDontTolerate: guidelinesDontTolerate,
        members: parseMembers(json['members']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
    } catch (e) {
      print('❌ Error parsing CommunityModel from JSON: $e');
      print('   JSON: $json');
      // Return a default community model to prevent crashes
      return CommunityModel(
        id: '',
        name: json['name']?.toString() ?? 'Unknown',
        description: json['description']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        createdBy: '',
        createdByType: '',
        logoPath: json['logo_path']?.toString() ?? '',
        tagId: 0,
        guidelinesEncourage: '',
        guidelinesDiscourage: '',
        guidelinesDontTolerate: '',
        members: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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
      'guidelines_encourage': guidelinesEncourage,
      'guidelines_discourage': guidelinesDiscourage,
      'guidelines_dont_tolerate': guidelinesDontTolerate,
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

