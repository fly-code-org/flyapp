// post_model.dart
class Post {
  final String id;
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
  final int bookmarks;

  /// Optional poll options (if this post is a poll)
  final List<String>? pollOptions;
  
  /// List of user IDs who have liked this post (for checking if current user has liked)
  final List<String>? likedBy;
  
  /// List of user IDs who have bookmarked this post (for checking if current user has bookmarked)
  final List<String>? bookmarkedBy;

  const Post({
    required this.id,
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
    required this.bookmarks,
    this.pollOptions,
    this.likedBy,
    this.bookmarkedBy,
  });

  // Optional: convenience factory to build from map (if you need later)
  factory Post.fromMap(Map<String, dynamic> m) => Post(
    id: m['id'] as String? ?? '',
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
    bookmarks: m['bookmarks'] as int? ?? 0,
    pollOptions: (m['pollOptions'] as List<dynamic>?)?.cast<String>(),
    likedBy: (m['likedBy'] as List<dynamic>?)?.cast<String>(),
    bookmarkedBy: (m['bookmarkedBy'] as List<dynamic>?)?.cast<String>(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
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
    'bookmarks': bookmarks,
    'pollOptions': pollOptions,
    'likedBy': likedBy,
    'bookmarkedBy': bookmarkedBy,
  };
  
  /// Creates a copy of this Post with updated likes count
  Post copyWith({
    String? id,
    String? profileUrl,
    String? username,
    String? timestamp,
    String? tagIconUrl,
    String? text,
    String? mediaUrl,
    List<String>? mediaUrls,
    bool? isVideo,
    int? likes,
    int? comments,
    int? views,
    int? bookmarks,
    List<String>? pollOptions,
    List<String>? likedBy,
    List<String>? bookmarkedBy,
  }) {
    return Post(
      id: id ?? this.id,
      profileUrl: profileUrl ?? this.profileUrl,
      username: username ?? this.username,
      timestamp: timestamp ?? this.timestamp,
      tagIconUrl: tagIconUrl ?? this.tagIconUrl,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isVideo: isVideo ?? this.isVideo,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      bookmarks: bookmarks ?? this.bookmarks,
      pollOptions: pollOptions ?? this.pollOptions,
      likedBy: likedBy ?? this.likedBy,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
    );
  }
}
