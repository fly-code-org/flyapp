// domain/entities/create_post_request.dart
import 'package:equatable/equatable.dart';
import 'post.dart';

class CreatePostRequest extends Equatable {
  final int tagId; // Required: tag ID for the post
  final String? content;
  final List<Attachment> attachments;
  final Poll? poll;
  /// When set, post is associated with this community (e.g. MHP's community) so it appears in community feed and MHP Activities.
  final String? communityId;

  const CreatePostRequest({
    required this.tagId,
    this.content,
    this.attachments = const [],
    this.poll,
    this.communityId,
  });

  @override
  List<Object?> get props => [tagId, content, attachments, poll, communityId];
}



