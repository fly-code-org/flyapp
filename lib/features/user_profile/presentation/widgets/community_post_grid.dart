import 'package:flutter/material.dart';

class CommunityMediaSection extends StatelessWidget {
  final String type;
  final List<String>? postIds; // For Activities tab
  final List<Map<String, dynamic>>? bookmarkedPosts; // For Bookmarks tab

  const CommunityMediaSection({
    super.key,
    required this.type,
    this.postIds,
    this.bookmarkedPosts,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which data to use
    List<Map<String, dynamic>> posts = [];

    if (type == "Activities" && postIds != null && postIds!.isNotEmpty) {
      // For activities, we have post IDs
      // TODO: Fetch actual post data from post IDs
      // For now, show placeholder
      posts = postIds!.map((postId) => {
        "type": "image",
        "url": "https://picsum.photos/200?random=$postId",
        "post_id": postId,
      }).toList();
    } else if (type == "Bookmarks" &&
        bookmarkedPosts != null &&
        bookmarkedPosts!.isNotEmpty) {
      // For bookmarks, we have bookmarked post data
      // TODO: Fetch actual post data from bookmarked post IDs
      // For now, show placeholder
      posts = bookmarkedPosts!.map((bookmark) => {
        "type": "image",
        "url": "https://picsum.photos/200?random=${bookmark['post_id']}",
        "post_id": bookmark['post_id'],
        "bookmarked_at": bookmark['bookmarked_at'],
      }).toList();
    } else {
      // No data - show empty state
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            type == "Activities"
                ? "No activities yet"
                : "No bookmarks yet",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        final type = post['type'];

        Widget child;
        if (type == "image") {
          child = Image.network(post['url']!, fit: BoxFit.cover);
        } else if (type == "video") {
          child = Stack(
            fit: StackFit.expand,
            children: [
              Image.network(post['url']!, fit: BoxFit.cover),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          );
        } else {
          child = Container(
            color: Colors.grey[200],
            child: Center(
              child: Text(
                post['content']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                type == "image"
                    ? Icons.photo
                    : type == "video"
                    ? Icons.videocam
                    : Icons.text_snippet,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}
