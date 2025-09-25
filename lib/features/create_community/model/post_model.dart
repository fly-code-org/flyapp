class PostModel {
  final String id;
  final String type; // "image", "video", "text"
  final String content; // url for image/video or text content
  final int likes;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.type,
    required this.content,
    required this.likes,
    required this.createdAt,
  });
}
