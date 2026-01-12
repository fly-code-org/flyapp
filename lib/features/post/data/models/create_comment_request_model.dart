// data/models/create_comment_request_model.dart
import '../../domain/entities/create_comment_request.dart';

class CreateCommentRequestModel extends CreateCommentRequest {
  const CreateCommentRequestModel({
    required super.postId,
    super.parentCommentId,
    required super.text,
  });

  factory CreateCommentRequestModel.fromEntity(CreateCommentRequest entity) {
    return CreateCommentRequestModel(
      postId: entity.postId,
      parentCommentId: entity.parentCommentId,
      text: entity.text,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'post_id': postId,
      'text': text,
    };
    if (parentCommentId != null) {
      json['parent_comment_id'] = parentCommentId;
    }
    return json;
  }
}
