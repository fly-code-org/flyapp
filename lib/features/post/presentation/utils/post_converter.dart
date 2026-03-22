// presentation/utils/post_converter.dart
import '../../../home/model/post_model.dart' as ui_model;
import '../../domain/entities/post.dart' as api_model;
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../features/interests/data/models/tag_icon_mapping.dart';
import '../../../../features/user_profile/data/utils/default_profile_picture.dart';

class PostConverter {
  /// Gets a random default profile picture based on user ID
  /// Uses userId as seed for Random to ensure same user always gets the same picture
  /// but appears random across different users
  static String _getDefaultProfilePicture(String userId) {
    return DefaultProfilePicture.getRandomProfilePicture(userId);
  }

  /// Converts API Post entity to UI Post model
  static ui_model.Post toUIPost(api_model.Post apiPost, {
    String? profileUrl,
    String? username,
  }) {
    // Extract image URLs from attachments
    final imageUrls = apiPost.attachments
        .where((a) => a.type == 'image')
        .map((a) => a.url)
        .toList();
    
    // Check if there's a video
    final videoAttachments = apiPost.attachments.where((a) => a.type == 'video').toList();
    final hasVideo = videoAttachments.isNotEmpty;
    final videoUrl = hasVideo ? videoAttachments.first.url : '';
    
    // Get tag icon from tag ID (using TagIconMapping for both social and support tags)
    String tagIconUrl = '';
    try {
      if (apiPost.tagId > 0) {
        // Get SVG asset path directly from tag ID
        tagIconUrl = TagIconMapping.getTagIconPathById(apiPost.tagId);
      }
    } catch (e) {
      // Silently fail - tag icon is optional, don't block post conversion
      print('⚠️ [POST CONVERTER] Error getting tag icon for tagId ${apiPost.tagId}: $e');
      tagIconUrl = '';
    }
    
    // Format timestamp
    final now = DateTime.now();
    final difference = now.difference(apiPost.createdAt);
    String timestamp;
    if (difference.inDays > 0) {
      timestamp = '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      timestamp = '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      timestamp = '${difference.inMinutes}m';
    } else {
      timestamp = 'now';
    }
    
    // Extract poll options if exists
    final pollOptions = apiPost.poll?.options
        .map((o) => o.text)
        .toList();
    
    // Use fallbacks if profileUrl or username are null or empty
    // For profileUrl, process through ProfilePictureHelper to handle asset paths vs CDN URLs
    String finalProfileUrl;
    if (profileUrl != null && profileUrl.isNotEmpty) {
      finalProfileUrl = ProfilePictureHelper.getProfilePictureUrl(profileUrl);
    } else {
      // Use a deterministic default SVG profile picture from CDN
      finalProfileUrl = _getDefaultProfilePicture(apiPost.authorId);
    }
    final finalUsername = (username != null && username.isNotEmpty)
        ? username
        : 'user_${apiPost.authorId.substring(0, 8)}';
    
    return ui_model.Post(
      id: apiPost.id,
      profileUrl: finalProfileUrl,
      username: finalUsername,
      timestamp: timestamp,
      tagIconUrl: tagIconUrl,
      text: apiPost.content ?? '',
      mediaUrl: hasVideo ? videoUrl : (imageUrls.isNotEmpty ? imageUrls[0] : null),
      mediaUrls: imageUrls.isNotEmpty ? imageUrls : null,
      isVideo: hasVideo,
      likes: apiPost.likeCount,
      comments: apiPost.commentCount,
      views: apiPost.viewCount,
      bookmarks: apiPost.bookmarkCount,
      pollOptions: pollOptions,
      likedBy: apiPost.likes, // Pass the list of user IDs who liked the post
      bookmarkedBy: apiPost.bookmarkedBy, // Pass the list of user IDs who bookmarked the post
    );
  }
  
  /// Converts list of API Post entities to UI Post models
  static List<ui_model.Post> toUIPosts(List<api_model.Post> apiPosts, {
    Map<String, String>? authorProfileUrls,
    Map<String, String>? authorUsernames,
  }) {
    return apiPosts.map((apiPost) {
      final authorId = apiPost.authorId;
      final username = authorUsernames?[authorId];
      final profileUrl = authorProfileUrls?[authorId];
      return toUIPost(
        apiPost,
        profileUrl: profileUrl,
        username: username,
      );
    }).toList();
  }
}

