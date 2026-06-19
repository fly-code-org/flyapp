import 'package:flutter/material.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/core/widgets/safe_svg_icon.dart';
import 'package:fly/features/explore/presentation/controllers/explore_tag_controller.dart';
import 'package:fly/features/home/presentation/widgets/social_post.dart';
import 'package:get/get.dart';

class ExploreTagScreen extends StatelessWidget {
  const ExploreTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final tagId = args['tagId'] as int? ?? 0;
    final tagIconUrl = args['tagIconUrl'] as String? ?? '';

    final controller = Get.put(
      ExploreTagController(tagId: tagId, initialTagIconUrl: tagIconUrl),
      tag: 'explore_tag_$tagId',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: Column(
        children: [
          _TagHeader(controller: controller),
          _FilterTabs(controller: controller),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Expanded(child: _PostList(controller: controller)),
        ],
      ),
    );
  }
}

class _TagHeader extends StatelessWidget {
  final ExploreTagController controller;
  const _TagHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0EEFF),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 16, top: 8, bottom: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Explore Tags',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // Tag info row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  // Tag icon circle
                  Obx(() => _TagCircleIcon(iconUrl: controller.tagIconUrl.value)),
                  const SizedBox(width: 12),
                  // Name + stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.tagName.value.isNotEmpty
                              ? controller.tagName.value
                              : '...',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          '${_formatCount(controller.postCount.value)} posts'
                          ' · '
                          '${_formatCount(controller.followerCount.value)} followers',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Follow / Following button
                  _FollowButton(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _TagCircleIcon extends StatelessWidget {
  final String iconUrl;
  const _TagCircleIcon({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8B4D8),
      ),
      padding: const EdgeInsets.all(12),
      child: SafeSvgIcon(
        assetPath: iconUrl,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final ExploreTagController controller;
  const _FollowButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final followed = controller.isFollowed.value;
      final loading = controller.isFollowLoading.value;

      if (followed) {
        return OutlinedButton(
          onPressed: loading ? null : controller.toggleFollow,
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.black87),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Following',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                ),
        );
      } else {
        return ElevatedButton(
          onPressed: loading ? null : controller.toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF855DFC),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Follow', style: TextStyle(fontWeight: FontWeight.w600)),
        );
      }
    });
  }
}

class _FilterTabs extends StatelessWidget {
  final ExploreTagController controller;
  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Obx(() {
        final selected = controller.selectedFilter.value;
        return Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selected == 'all',
              onTap: () => controller.fetchPosts(filter: 'all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Media',
              isSelected: selected == 'media',
              onTap: () => controller.fetchPosts(filter: 'media'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Poll',
              isSelected: selected == 'poll',
              onTap: () => controller.fetchPosts(filter: 'poll'),
            ),
          ],
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final ExploreTagController controller;
  const _PostList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      final posts = controller.posts;
      if (posts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No posts yet in this tag.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          final key = post.id.isNotEmpty ? post.id : '${post.timestamp}_$index';
          return SocialPost(
            key: ValueKey('tag_post_${key}_$index'),
            post: post,
            isSocialTab: true,
          );
        },
      );
    });
  }
}
