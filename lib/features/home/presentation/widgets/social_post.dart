import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SocialPost extends StatefulWidget {
  final Post post;
  final bool isSocialTab;

  const SocialPost({super.key, required this.post, this.isSocialTab = true});

  @override
  _SocialPostState createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  VideoPlayerController? _videoController;
  bool isLiked = false;
  bool isBookmarked = false;
  bool isTextExpanded = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.post.isVideo && !kIsWeb) {
      _videoController =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.post.mediaUrl ?? ''),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            )
            ..initialize().then((_) {
              setState(() {});
              _videoController?.setLooping(true);
              _videoController?.setVolume(0);
              _videoController?.play();
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildProfilePicture() {
    if (widget.isSocialTab) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(widget.post.profileUrl),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.post.profileUrl,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _buildImageCarousel(List<String> mediaUrls) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mediaUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: mediaUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        if (mediaUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildProfilePicture(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.post.timestamp,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    'assets/icon/social-tags/artAndCreativity.svg',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),

          // Post Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: LayoutBuilder(
              builder: (context, size) {
                final textSpan = TextSpan(
                  text: widget.post.text,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                );
                final textPainter = TextPainter(
                  text: textSpan,
                  maxLines: isTextExpanded ? null : 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: size.maxWidth);
                final isOverflow = textPainter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.text,
                      maxLines: isTextExpanded ? null : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isOverflow)
                      GestureDetector(
                        onTap: () =>
                            setState(() => isTextExpanded = !isTextExpanded),
                        child: Text(
                          isTextExpanded ? "See less" : "See more",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Media
          if (widget.post.isVideo && _videoController != null)
            _videoController!.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.volume == 0) {
                          _videoController!.setVolume(1);
                        } else {
                          _videoController!.setVolume(0);
                        }
                      });
                    },
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Container(
                    height: 200,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  )
          else if (widget.post.mediaUrls != null &&
              widget.post.mediaUrls!.isNotEmpty)
            _buildImageCarousel(widget.post.mediaUrls!)
          else
            const SizedBox.shrink(),

          // Action Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isLiked = !isLiked),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text("${widget.post.likes + (isLiked ? 1 : 0)}"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.comment_outlined, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${widget.post.comments}"),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(Icons.share_outlined, color: Colors.grey),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${widget.post.views}"),
                  ],
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => setState(() => isBookmarked = !isBookmarked),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
