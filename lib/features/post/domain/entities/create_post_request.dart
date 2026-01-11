// domain/entities/create_post_request.dart
import 'package:equatable/equatable.dart';
import 'post.dart';

class CreatePostRequest extends Equatable {
  final int tagId; // Required: tag ID for the post
  final String? content;
  final List<Attachment> attachments;
  final Poll? poll;

  const CreatePostRequest({
    required this.tagId,
    this.content,
    this.attachments = const [],
    this.poll,
  });

  @override
  List<Object?> get props => [tagId, content, attachments, poll];
}



