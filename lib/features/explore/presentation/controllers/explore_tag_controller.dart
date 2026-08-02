import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/features/home/model/post_model.dart';
import 'package:fly/features/interests/data/models/tag_icon_mapping.dart';
import 'package:fly/features/interests/data/server_tag_catalog.dart';
import 'package:fly/features/interests/domain/usecases/follow_tag.dart';
import 'package:fly/features/interests/domain/usecases/get_tag_info.dart';
import 'package:fly/features/interests/domain/usecases/unfollow_tag.dart';
import 'package:fly/features/post/domain/usecases/get_posts_by_tag.dart';
import 'package:fly/features/post/presentation/services/user_profile_service.dart';
import 'package:fly/features/post/presentation/utils/post_converter.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_mhp_profile.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_user_profile.dart';
import 'package:get/get.dart';

class ExploreTagController extends GetxController {
  final int tagId;
  final String initialTagIconUrl;

  ExploreTagController({required this.tagId, required this.initialTagIconUrl});

  // Tag metadata
  final tagName = ''.obs;
  final tagIconUrl = ''.obs;
  final postCount = 0.obs;
  final followerCount = 0.obs;

  // Follow state
  final isFollowed = false.obs;
  final isFollowLoading = false.obs;

  // Posts
  final posts = <Post>[].obs;
  final isLoadingPosts = false.obs;
  final selectedFilter = 'all'.obs; // 'all' | 'media' | 'poll'

  // Error
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tagIconUrl.value = initialTagIconUrl;
    _resolveTagName();
    _loadTagInfo();
    _loadFollowState();
    fetchPosts();
  }

  void _resolveTagName() {
    final catalog = sl<ServerTagCatalog>();
    final name = catalog.displayNameForTagId(tagId) ?? '';
    tagName.value = name;
  }

  Future<void> _loadTagInfo() async {
    try {
      final getTagInfo = sl<GetTagInfo>();
      final info = await getTagInfo.call(tagId);
      if (info.isNotEmpty) {
        tagName.value = info['name'] as String? ?? tagName.value;
        postCount.value = (info['post_count'] as num?)?.toInt() ?? 0;
        followerCount.value = (info['follower_count'] as num?)?.toInt() ?? 0;
        // Resolve icon from name if we got a better name from server
        if (tagIconUrl.value.isEmpty && tagName.value.isNotEmpty) {
          tagIconUrl.value = TagIconMapping.getTagIconPath(tagName.value);
        }
      }
    } catch (_) {
      // Non-fatal: tag info enriches the UI but isn't required
    }
  }

  Future<void> _loadFollowState() async {
    try {
      final token = await TokenStorage.getToken();
      final isMhp = JwtDecoder.isMhp(token);
      Map<String, dynamic> profile;
      if (isMhp) {
        profile = await sl<GetMhpProfile>().call();
      } else {
        profile = await sl<GetUserProfile>().call();
      }
      final interests = profile['followed_interests'];
      if (interests is List) {
        isFollowed.value = interests.any((i) {
          if (i is Map<String, dynamic>) {
            final id = i['tag_id'];
            if (id is int) return id == tagId;
            if (id is num) return id.toInt() == tagId;
          }
          return false;
        });
      }
    } catch (_) {
      // Default to not-followed
    }
  }

  Future<void> fetchPosts({String? filter}) async {
    final type = filter ?? selectedFilter.value;
    if (filter != null) selectedFilter.value = filter;

    isLoadingPosts.value = true;
    errorMessage.value = '';
    try {
      final getPostsByTag = sl<GetPostsByTag>();
      final rawPosts = await getPostsByTag.call(tagId, postType: type);

      // Fetch author profiles for usernames and pictures
      final authorIds = rawPosts.map((p) => p.authorId).toSet().toList();
      final userProfileService = UserProfileService();
      final authorProfiles = await userProfileService.getUserProfiles(authorIds);

      final authorProfileUrls = <String, String>{};
      final authorUsernames = <String, String>{};

      for (var entry in authorProfiles.entries) {
        final oderId = entry.key;
        final profile = entry.value;
        final usernameValue = profile['username'];
        if (usernameValue != null) {
          final s = usernameValue.toString().trim();
          if (s.isNotEmpty) authorUsernames[oderId] = s;
        }
        final picPath = profile['picture_path'];
        if (picPath != null) {
          final p = picPath.toString().trim();
          if (p.isNotEmpty) authorProfileUrls[oderId] = p;
        }
      }

      posts.value = PostConverter.toUIPosts(
        rawPosts,
        authorProfileUrls: authorProfileUrls,
        authorUsernames: authorUsernames,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> toggleFollow() async {
    if (isFollowLoading.value) return;
    isFollowLoading.value = true;
    final wasFollowed = isFollowed.value;
    isFollowed.value = !wasFollowed; // optimistic
    try {
      if (wasFollowed) {
        await sl<UnfollowTag>().call(tagId);
        followerCount.value = (followerCount.value - 1).clamp(0, 999999999);
      } else {
        await sl<FollowTag>().call(tagId, tagName.value);
        followerCount.value = followerCount.value + 1;
      }
    } catch (e) {
      isFollowed.value = wasFollowed; // revert
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFollowLoading.value = false;
    }
  }
}
