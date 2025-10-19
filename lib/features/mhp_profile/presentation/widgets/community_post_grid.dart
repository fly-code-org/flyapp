import 'package:flutter/material.dart';

class CommunityMediaSection extends StatelessWidget {
  final String type;
  const CommunityMediaSection({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    // Mocked posts
    final posts = [
      {"type": "image", "url": "https://picsum.photos/200"},
      {"type": "video", "url": "https://picsum.photos/201"},
      {"type": "text", "content": "This is a text post"},
      {"type": "image", "url": "https://picsum.photos/202"},
      {"type": "video", "url": "https://picsum.photos/203"},
      {"type": "text", "content": "Another text post"},
      {"type": "image", "url": "https://picsum.photos/204"},
      {"type": "video", "url": "https://picsum.photos/205"},
      {"type": "image", "url": "https://picsum.photos/206"},
      {"type": "image", "url": "https://picsum.photos/204"},
      {"type": "video", "url": "https://picsum.photos/205"},
      {"type": "image", "url": "https://picsum.photos/206"},
    ];

    return GridView.builder(
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
