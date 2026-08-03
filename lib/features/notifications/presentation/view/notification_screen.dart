import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/features/home/presentation/views/post_detail_screen.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/add_review_bottom_sheet.dart';
import 'package:fly/features/post/presentation/controllers/post_controller.dart';
import 'package:fly/features/post/presentation/services/user_profile_service.dart';
import 'package:fly/features/post/presentation/utils/post_converter.dart';
import 'package:fly/features/post/presentation/widgets/comment_bottom_sheet.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import '../../controller/notification_controller.dart';
import '../../model/notification_model.dart';
import '../widget/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  // Reuse the permanent controller initialised in home.dart; fall back to creating one if needed.
  final NotificationController controller = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController(), permanent: true);

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => popOrGoHome(context),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_all') controller.markAllAsRead();
                if (value == 'clear_all') controller.clearAll();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'mark_all', child: Text('Mark all as read')),
                PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
              ],
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchNotifications,
            child: ListView.builder(
              itemCount: controller.notifications.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == controller.notifications.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: controller.isLoadingMore.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: controller.loadMore,
                              child: const Text(
                                'Load more',
                                style: TextStyle(
                                  color: Color(0xFF855DFC),
                                  
                                ),
                              ),
                            ),
                    ),
                  );
                }
                final notif = controller.notifications[index];
                return NotificationCard(
                  notification: notif,
                  onTap: () {
                    controller.markAsRead(notif.id);
                    if (notif.type == 'payment_success' ||
                        notif.type == 'session_reminder' ||
                        notif.type == 'session_booked') {
                      Get.toNamed(AppRoutes.UserManageSessions);
                    } else if (notif.type == 'feedback_request') {
                      final mhpId = notif.metadata['mhp_id']?.toString() ?? '';
                      final mhpName = notif.metadata['mhp_name']?.toString() ?? 'your therapist';
                      final bookingId = notif.metadata['booking_id']?.toString() ?? '';
                      AddReviewBottomSheet.show(
                        context,
                        mhpId: mhpId,
                        mhpName: mhpName,
                        bookingId: bookingId,
                      );
                    } else if (notif.type == 'post_comment' || notif.type == 'comment_reply') {
                      _openComments(context, notif);
                    } else if (notif.isSocialNotification) {
                      _navigateToPost(context, notif);
                    }
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _openComments(BuildContext context, NotificationModel notif) {
    final postId = notif.postId;
    if (postId == null || postId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentBottomSheet(postId: postId),
    );
  }

  Future<void> _navigateToPost(BuildContext context, NotificationModel notif) async {
    final postId = notif.postId;
    if (postId == null || postId.isEmpty) return;

    final postController = Get.isRegistered<PostController>()
        ? Get.find<PostController>()
        : Get.put(sl<PostController>());

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await postController.fetchPostsByIds([postId]);
      final posts = postController.posts;
      if (posts.isEmpty) {
        Get.back();
        Get.snackbar('Error', 'Post not found', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final domainPost = posts.first;
      final userProfileService = UserProfileService();
      final profiles = await userProfileService.getUserProfiles([domainPost.authorId]);
      final profile = profiles[domainPost.authorId];
      final username = profile?['username']?.toString();
      final profileUrl = profile?['picture_path']?.toString();

      final uiPost = PostConverter.toUIPost(
        domainPost,
        username: username,
        profileUrl: profileUrl,
      );

      Get.back();
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: uiPost)),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to load post', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
