// data/models/create_post_request_model.dart
import '../../domain/entities/create_post_request.dart';
import 'post_model.dart';

class CreatePostRequestModel extends CreatePostRequest {
  const CreatePostRequestModel({
    required super.tagId,
    super.content,
    super.attachments = const [],
    super.poll,
    super.communityId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'tag_id': tagId,
    };

    if (content != null && content!.trim().isNotEmpty) {
      json['content'] = content!.trim();
    }

    if (attachments.isNotEmpty) {
      json['attachments'] = attachments
          .map((a) => (a as AttachmentModel).toJson())
          .toList();
    }

    if (poll != null) {
      json['poll'] = (poll as PollModel).toJson();
    }

    if (communityId != null && communityId!.trim().isNotEmpty) {
      json['community_id'] = communityId!.trim();
    }

    return json;
  }
}

