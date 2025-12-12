// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interests_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
      tagId: (json['tag_id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
      'tag_id': instance.tagId,
      'name': instance.name,
    };

InterestsRequestModel _$InterestsRequestModelFromJson(
        Map<String, dynamic> json) =>
    InterestsRequestModel(
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      communities: (json['communities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$InterestsRequestModelToJson(
        InterestsRequestModel instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'communities': instance.communities,
    };
