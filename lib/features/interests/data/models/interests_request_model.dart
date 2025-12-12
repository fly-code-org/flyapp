// data/models/interests_request_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'interests_request_model.g.dart';

@JsonSerializable()
class TagModel {
  @JsonKey(name: 'tag_id')
  final int tagId;
  final String name;

  TagModel({
    required this.tagId,
    required this.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagModelToJson(this);
}

@JsonSerializable()
class InterestsRequestModel {
  final List<TagModel> tags;
  final List<String>? communities;

  InterestsRequestModel({
    required this.tags,
    this.communities,
  });

  factory InterestsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$InterestsRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$InterestsRequestModelToJson(this);
}

