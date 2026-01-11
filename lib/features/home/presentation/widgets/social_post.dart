import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/core/widgets/safe_svg_icon.dart';
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
  PageController? _pageController;
  bool isLiked = false;
  bool isBookmarked = false;
  bool isTextExpanded = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    // Only create PageController if there are multiple images
    if (widget.post.mediaUrls != null && widget.post.mediaUrls!.length > 1) {
      _pageController = PageController();
    }
    
    if (widget.post.isVideo && !kIsWeb && widget.post.mediaUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(
              Uri.parse(widget.post.mediaUrl!),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            )
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _videoController?.setLooping(true);
                _videoController?.setVolume(0);
                _videoController?.play();
              }
            }).catchError((error) {
              print('❌ [SOCIAL POST] Error initializing video: $error');
              if (mounted) {
                setState(() {});
              }
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  Widget _buildProfilePicture() {
    final profileUrl = widget.post.profileUrl;
    
    // Check if this is a local asset path
    final isLocalAsset = ProfilePictureHelper.isLocalAsset(profileUrl);
    
    Widget profileWidget;
    
    if (isLocalAsset) {
      // Handle local asset profile pictures (e.g., /assets/profile_2.svg)
      final assetPath = ProfilePictureHelper.getAssetPath(profileUrl);
      final isSvg = assetPath.toLowerCase().endsWith('.svg');
      
      if (isSvg) {
        profileWidget = SvgPicture.asset(
          assetPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          errorBuilder: (context, error, stackTrace) {
            debugPrint('⚠️ [SOCIAL POST] Error loading SVG profile picture from assets: $assetPath - $error');
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          semanticsLabel: 'Profile picture',
        );
      } else {
        // Handle regular image from assets
        profileWidget = Image.asset(
          assetPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('⚠️ [SOCIAL POST] Error loading profile image from assets: $assetPath - $error');
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
        );
      }
    } else {
      // Handle network/CDN profile pictures
      final isSvg = profileUrl.toLowerCase().endsWith('.svg');
      
      if (isSvg) {
        // Handle SVG profile pictures (from CDN) with error handling
        // Use errorBuilder to catch SVG parsing errors (async errors won't be caught by try-catch)
        profileWidget = SvgPicture.network(
          profileUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          // errorBuilder catches SVG parsing errors (like "unhandled element")
          errorBuilder: (context, error, stackTrace) {
            debugPrint('⚠️ [SOCIAL POST] Error loading SVG profile picture: $profileUrl - $error');
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          semanticsLabel: 'Profile picture',
        );
      } else {
        // Handle regular image profile pictures
        profileWidget = CachedNetworkImage(
          imageUrl: profileUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          errorWidget: (context, url, error) {
            // Log error for debugging but don't block
            print('⚠️ [SOCIAL POST] Error loading profile image: $url - $error');
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            );
          },
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          memCacheWidth: 80,
          memCacheHeight: 80,
          // Add timeout to prevent hanging
          httpHeaders: const {'Cache-Control': 'max-age=3600'},
        );
      }
    }
    
    if (widget.isSocialTab) {
      return ClipOval(child: profileWidget);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: profileWidget,
      );
    }
  }
  
  Widget _buildTagIcon(String iconPath) {
    // Tag icons are asset paths, use SafeSvgIcon for robust error handling
    if (iconPath.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Use SafeSvgIcon which handles SVG parsing errors gracefully
    return SafeSvgIcon(
      assetPath: iconPath,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      fallback: const Icon(Icons.tag, size: 16, color: Colors.grey),
    );
  }

  Widget _buildImageCarousel(List<String> mediaUrls) {
    // If single image, no need for PageView
    if (mediaUrls.length == 1) {
      return RepaintBoundary(
        child: CachedNetworkImage(
          imageUrl: mediaUrls[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
          placeholder: (context, url) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          // Limit image resolution to prevent memory issues
          maxWidthDiskCache: 800,
          maxHeightDiskCache: 800,
          memCacheWidth: 800,
          memCacheHeight: 800,
        ),
      );
    }
    
    // Multiple images - use PageView
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController ?? PageController(),
            itemCount: mediaUrls.length,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
            },
            itemBuilder: (context, index) {
              return RepaintBoundary(
                key: ValueKey('image_$index'),
                child: CachedNetworkImage(
                  imageUrl: mediaUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  // Limit image resolution to prevent memory issues
                  maxWidthDiskCache: 800,
                  maxHeightDiskCache: 800,
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              mediaUrls.length,
              (index) => Container(
                key: ValueKey('dot_$index'),
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
    return RepaintBoundary(
      child: Card(
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
                // Display tag icon if available (with safe async loading)
                if (widget.post.tagIconUrl.isNotEmpty)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: _buildTagIcon(widget.post.tagIconUrl),
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
      ),
    );
  }
}
