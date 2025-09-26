class Post {
  final String profileUrl;
  final String username;
  final String timestamp;
  final String tagIconUrl;
  final String text;
  final String mediaUrl;
  final bool isVideo;
  final int likes;
  final int comments;
  final int views;

  Post({
    required this.profileUrl,
    required this.username,
    required this.timestamp,
    required this.tagIconUrl,
    required this.text,
    required this.mediaUrl,
    required this.isVideo,
    required this.likes,
    required this.comments,
    required this.views,
  });
}
