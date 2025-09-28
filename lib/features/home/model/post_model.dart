// post_model.dart
class Post {
  final String profileUrl;
  final String username;
  final String timestamp;
  final String tagIconUrl;
  final String text;

  /// For backwards compatibility you can keep a single mediaUrl (first media)
  final String? mediaUrl;

  /// Multiple media support (images). Null or empty if none.
  final List<String>? mediaUrls;

  /// true => mediaUrl points to a video; false => images
  final bool isVideo;

  final int likes;
  final int comments;
  final int views;

  /// Optional poll options (if this post is a poll)
  final List<String>? pollOptions;

  const Post({
    required this.profileUrl,
    required this.username,
    required this.timestamp,
    required this.tagIconUrl,
    required this.text,
    this.mediaUrl,
    this.mediaUrls,
    required this.isVideo,
    required this.likes,
    required this.comments,
    required this.views,
    this.pollOptions,
  });

  // Optional: convenience factory to build from map (if you need later)
  factory Post.fromMap(Map<String, dynamic> m) => Post(
    profileUrl: m['profileUrl'] as String? ?? '',
    username: m['username'] as String? ?? '',
    timestamp: m['timestamp'] as String? ?? '',
    tagIconUrl: m['tagIconUrl'] as String? ?? '',
    text: m['text'] as String? ?? '',
    mediaUrl: m['mediaUrl'] as String?,
    mediaUrls: (m['mediaUrls'] as List<dynamic>?)?.cast<String>(),
    isVideo: m['isVideo'] as bool? ?? false,
    likes: m['likes'] as int? ?? 0,
    comments: m['comments'] as int? ?? 0,
    views: m['views'] as int? ?? 0,
    pollOptions: (m['pollOptions'] as List<dynamic>?)?.cast<String>(),
  );

  Map<String, dynamic> toMap() => {
    'profileUrl': profileUrl,
    'username': username,
    'timestamp': timestamp,
    'tagIconUrl': tagIconUrl,
    'text': text,
    'mediaUrl': mediaUrl,
    'mediaUrls': mediaUrls,
    'isVideo': isVideo,
    'likes': likes,
    'comments': comments,
    'views': views,
    'pollOptions': pollOptions,
  };
}
