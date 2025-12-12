// data/models/interests_response_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'interests_response_model.g.dart';

@JsonSerializable()
class InterestsResponseModel {
  final String msg;
  final dynamic data;

  InterestsResponseModel({
    required this.msg,
    this.data,
  });

  factory InterestsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$InterestsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$InterestsResponseModelToJson(this);
}

