import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/features/community/domain/entities/explore_search_result.dart';
import 'package:fly/features/community/domain/usecases/search_explore.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:fly/features/community/domain/usecases/get_communities_by_type.dart';
import 'package:fly/features/explore/presentation/widgets/community_list_horizontal.dart';
import 'package:fly/features/explore/presentation/widgets/conversation_card.dart';
import 'package:fly/features/explore/presentation/widgets/search_bar.dart';
import 'package:fly/features/explore/presentation/widgets/social_tag_h.dart';
import 'package:fly/features/interests/data/server_tag_catalog.dart';
import 'package:fly/features/interests/domain/usecases/follow_tag.dart';
import 'package:fly/features/interests/domain/usecases/unfollow_tag.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/widgets/square_entity_avatar.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_mhp_profile.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_user_profile.dart';
import 'package:fly/core/services/streak_engagement_service.dart';
import 'package:fly/features/streak/presentation/streak_detail_sheet.dart';
import 'package:fly/features/streak/presentation/streak_view_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  bool _searchLoading = false;
  ExploreSearchResult? _searchResults;

  // ✅ Use asset paths instead of network URLs
  final List<Map<String, String>> socialTags = [
    {
      "categoryLabel": "Respect",
      "imagePath": "assets/icon/social-tags/artAndCreativity.svg",
      "rightText": "Art & Creatives",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/awdorable.svg",
      "rightText": "Awwdorable",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/funAndHumor.svg",
      "rightText": "Fun & Humor",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/lifestyle.svg",
      "rightText": "Lifestyle",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/motivational.svg",
      "rightText": "Motivational",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/moviesAndShows.svg",
      "rightText": "Movies & Shows",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/newsAndInsights.svg",
      "rightText": "News & Insights",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/peace.svg",
      "rightText": "Peace",
    },
    {
      "categoryLabel": "On Topic",
      "imagePath": "assets/icon/social-tags/wordsOfWisdom.svg",
      "rightText": "Words of Wisdom",
    },
  ];

  // Loading states
  bool _isLoadingSocialCommunities = false;
  bool _isLoadingSupportCommunities = false;

  // Communities from API
  List<Map<String, dynamic>> _socialCommunities = [];
  List<Map<String, dynamic>> _supportCommunities = [];
  
  // Track followed tags by tag name (more reliable than ID for display)
  final Set<String> _followedTagNames = {};
  // Track followed community IDs from user profile (so MHP/user sees correct "joined" state)
  List<String> _followedCommunityIds = [];
  bool _isMhpRole = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initRole();
    _startExploreLoads();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StreakEngagementService.instance.recordEngagement(reason: 'explore_open');
    });
  }

  Future<void> _initRole() async {
    final t = await TokenStorage.getToken();
    if (!mounted) return;
    setState(() => _isMhpRole = JwtDecoder.isMhp(t));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = null;
        _searchLoading = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _runExploreSearch(q);
    });
  }

  Future<void> _runExploreSearch(String q) async {
    if (!mounted) return;
    setState(() => _searchLoading = true);
    try {
      final r = await sl<SearchExplore>().call(q);
      if (!mounted) return;
      setState(() {
        _searchResults = r;
        _searchLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _cdnLogoUrl(String logoPath) {
    if (logoPath.isEmpty) {
      return 'https://cdn.flyapp.in/assets/community-demo.png';
    }
    if (logoPath.startsWith('http://') || logoPath.startsWith('https://')) {
      return logoPath;
    }
    final path =
        logoPath.startsWith('/') ? logoPath.substring(1) : logoPath;
    return 'https://cdn.flyapp.in/$path';
  }

  Widget _buildSearchResultsPanel() {
    if (_searchController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    if (_searchLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final r = _searchResults;
    if (r == null) return const SizedBox.shrink();

    final social = r.communities
        .where((c) => c.type.toLowerCase() == 'social')
        .toList();
    final support = r.communities
        .where((c) => c.type.toLowerCase() == 'support')
        .toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 360),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.mhps.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'MHPs',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...r.mhps.map((m) {
                final pic = m.picturePath.isNotEmpty
                    ? ProfilePictureHelper.getProfilePictureUrl(m.picturePath)
                    : '';
                return ListTile(
                  dense: true,
                  leading: SquareEntityAvatar(
                    imageUrl: pic.isNotEmpty ? pic : null,
                    size: 44,
                    placeholderIcon: Icons.person_outline,
                  ),
                  title: Text(
                    m.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    m.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.mhpProfile,
                      arguments: {'userId': m.userId},
                    );
                  },
                );
              }),
            ],
            if (social.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Text(
                  'Social communities',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...social.map((c) {
                return ListTile(
                  dense: true,
                  leading: SquareEntityAvatar(
                    imageUrl: _cdnLogoUrl(c.logoPath),
                    size: 40,
                    placeholderIcon: Icons.groups_outlined,
                  ),
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.CommunitySupportProfile,
                      arguments: {'communityId': c.id},
                    );
                  },
                );
              }),
            ],
            if (support.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Text(
                  'Support communities',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...support.map((c) {
                return ListTile(
                  dense: true,
                  leading: SquareEntityAvatar(
                    imageUrl: _cdnLogoUrl(c.logoPath),
                    size: 40,
                    placeholderIcon: Icons.groups_outlined,
                  ),
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.CommunitySupportProfile,
                      arguments: {'communityId': c.id},
                    );
                  },
                );
              }),
            ],
            if (r.mhps.isEmpty && r.communities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No matches yet',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Future<void> _startExploreLoads() async {
    try {
      await sl<ServerTagCatalog>().ensureLoaded();
    } catch (e) {
      print('⚠️ [EXPLORE] Could not load tag catalog: $e');
    }
    if (!mounted) return;
    _loadSocialCommunities();
    _loadSupportCommunities();
    _loadFollowedTags();
  }

  int? _resolveTagId(String tagName) =>
      sl<ServerTagCatalog>().tagIdForName(tagName.trim());
  
  Future<void> _loadFollowedTags() async {
    try {
      final token = await TokenStorage.getToken();
      final isMhp = JwtDecoder.isMhp(token);

      if (isMhp) {
        print('🔍 [EXPLORE] MHP: Fetching MHP profile for followed tags and communities...');
        final getMhpProfile = sl<GetMhpProfile>();
        final profile = await getMhpProfile.call();
        _applyFollowedFromProfile(profile);
      } else {
        print('🔍 [EXPLORE] User: Fetching user profile to get followed tags and communities...');
        final getUserProfile = sl<GetUserProfile>();
        final profile = await getUserProfile.call();
        _applyFollowedFromProfile(profile);
      }
    } catch (e) {
      print('❌ [EXPLORE] Error loading followed tags/communities: $e');
      setState(() {
        _followedTagNames.clear();
        _followedCommunityIds = [];
      });
    }
  }

  void _applyFollowedFromProfile(Map<String, dynamic> profile) {
    setState(() {
      _followedTagNames.clear();
      if (profile.containsKey('followed_interests') &&
          profile['followed_interests'] is List) {
        final list = profile['followed_interests'] as List;
        for (var interest in list) {
          if (interest is Map<String, dynamic> &&
              interest.containsKey('name') &&
              interest['name'] is String) {
            final tagName = (interest['name'] as String).trim();
            _followedTagNames.add(tagName);
          }
        }
      }

      _followedCommunityIds = [];
      if (profile.containsKey('followed_communities') &&
          profile['followed_communities'] is List) {
        final list = profile['followed_communities'] as List;
        for (var item in list) {
          if (item is String) {
            _followedCommunityIds.add(item);
          }
        }
      }

      if (profile['streaks'] is Map<String, dynamic> &&
          Get.isRegistered<StreakViewModel>()) {
        Get.find<StreakViewModel>().applyFromProfileMap(
          profile['streaks'] as Map<String, dynamic>,
        );
      }
    });
  }
  
  bool _isTagFollowed(String tagName) {
    // Direct name comparison (more reliable than ID since IDs overlap between types)
    // Normalize tag name for comparison (trim whitespace)
    final normalizedTagName = tagName.trim();
    final isFollowed = _followedTagNames.contains(normalizedTagName);
    
    // Debug: log mismatches for troubleshooting
    if (!isFollowed && _followedTagNames.isNotEmpty) {
      // Check for case-insensitive match
      final lowerTagName = normalizedTagName.toLowerCase();
      final hasCaseInsensitiveMatch = _followedTagNames.any((followed) => 
        followed.toLowerCase() == lowerTagName
      );
      if (hasCaseInsensitiveMatch) {
        final matchedName = _followedTagNames.firstWhere((f) => f.toLowerCase() == lowerTagName);
        print('⚠️ [EXPLORE] Case mismatch: UI="$normalizedTagName" vs DB="$matchedName"');
        // Use case-insensitive match
        return true;
      }
    }
    
    return isFollowed;
  }
  
  Future<void> _toggleTag(String tagName) async {
    final tagId = _resolveTagId(tagName);
    if (tagId == null) {
      print('⚠️ Tag ID not found for: $tagName');
      return;
    }
    
    final isCurrentlyFollowed = _followedTagNames.contains(tagName);
    
    print('🔄 [EXPLORE] Toggling tag: $tagName (ID: $tagId, Currently followed: $isCurrentlyFollowed)');
    
    // Optimistic UI update
    setState(() {
      if (isCurrentlyFollowed) {
        _followedTagNames.remove(tagName);
        print('   📉 Removed from followed: $tagName');
      } else {
        _followedTagNames.add(tagName);
        print('   📈 Added to followed: $tagName');
      }
    });
    
    try {
      if (isCurrentlyFollowed) {
        // Unfollow tag
        final unfollowTag = sl<UnfollowTag>();
        await unfollowTag.call(tagId);
        print('✅ Unfollowed tag: $tagName');
        // Refresh from server to ensure consistency
        await _loadFollowedTags();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unfollowed $tagName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Follow tag
        final followTag = sl<FollowTag>();
        await followTag.call(tagId, tagName);
        print('✅ Followed tag: $tagName');
        // Refresh from server to ensure consistency
        await _loadFollowedTags();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Followed $tagName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error updating tag follow status: $e');
      // Revert optimistic update on error
      setState(() {
        if (isCurrentlyFollowed) {
          _followedTagNames.add(tagName);
        } else {
          _followedTagNames.remove(tagName);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSocialCommunities() async {
    setState(() {
      _isLoadingSocialCommunities = true;
    });

    try {
      final getCommunitiesByType = sl<GetCommunitiesByType>();
      final communities = await getCommunitiesByType.call('social');

      setState(() {
        _socialCommunities = communities.map((community) {
          // Convert relative path to full CDN URL
          String profilePicUrl;
          if (community.logoPath.isEmpty) {
            profilePicUrl = 'https://cdn.flyapp.in/assets/community-demo.png';
          } else if (community.logoPath.startsWith('http://') ||
              community.logoPath.startsWith('https://')) {
            // Already a full URL
            profilePicUrl = community.logoPath;
          } else {
            // Relative path - prepend CDN base URL
            // Remove leading slash if present to avoid double slashes
            final path = community.logoPath.startsWith('/')
                ? community.logoPath.substring(1)
                : community.logoPath;
            profilePicUrl = 'https://cdn.flyapp.in/$path';
          }

          return {
            'profilePicUrl': profilePicUrl,
            'communityName': community.name,
            'communityId': community.id,
            'followerCount': community.members?.length ?? 0,
            'members': community.members ?? [], // Store members array
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading social communities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading social communities: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSocialCommunities = false;
        });
      }
    }
  }

  /// "Top Support Square by MHP's" must list only MHP-created support communities.
  /// Also dedupes by id in case the API returns the same community more than once.
  List<Community> _uniqueMhpSupportCommunities(List<Community> raw) {
    final seen = <String>{};
    final out = <Community>[];
    for (final c in raw) {
      if (c.createdByType.toLowerCase() != 'mhp') continue;
      final key = c.id.isNotEmpty ? c.id : '${c.createdBy}_${c.tagId}';
      if (seen.add(key)) out.add(c);
    }
    return out;
  }

  Future<void> _loadSupportCommunities() async {
    setState(() {
      _isLoadingSupportCommunities = true;
    });

    try {
      final getCommunitiesByType = sl<GetCommunitiesByType>();
      final communities = await getCommunitiesByType.call('support');
      final mhpSupport = _uniqueMhpSupportCommunities(communities);

      setState(() {
        _supportCommunities = mhpSupport.map((community) {
          // Convert relative path to full CDN URL
          String profilePicUrl;
          if (community.logoPath.isEmpty) {
            profilePicUrl = 'https://cdn.flyapp.in/assets/community-demo.png';
          } else if (community.logoPath.startsWith('http://') ||
              community.logoPath.startsWith('https://')) {
            // Already a full URL
            profilePicUrl = community.logoPath;
          } else {
            // Relative path - prepend CDN base URL
            // Remove leading slash if present to avoid double slashes
            final path = community.logoPath.startsWith('/')
                ? community.logoPath.substring(1)
                : community.logoPath;
            profilePicUrl = 'https://cdn.flyapp.in/$path';
          }

          return {
            'profilePicUrl': profilePicUrl,
            'communityName': community.name,
            'communityId': community.id,
            'followerCount': community.members?.length ?? 0,
            'members': community.members ?? [], // Store members array
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading support communities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading support communities: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSupportCommunities = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                children: [
                  if (_isMhpRole) ...[
                    GestureDetector(
                      onTap: () {
                        if (!Get.isRegistered<StreakViewModel>()) return;
                        final vm = Get.find<StreakViewModel>();
                        showStreakDetailSheet(
                          context,
                          streakCount: vm.streakCount.value,
                          lastEngagedAt: vm.lastEngagedAt.value,
                        );
                      },
                      child: Obx(() {
                        if (!Get.isRegistered<StreakViewModel>()) {
                          return const SizedBox.shrink();
                        }
                        final n = Get.find<StreakViewModel>().streakCount.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            "🪽$n Streaks",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                SizedBox(width: 20),
                Text(
                  "MHPs, tags, communities and more... ",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: CustomSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),

            _buildSearchResultsPanel(),

            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConversationCard(
                      backgroundImagePath: 'assets/images/bg_fly.png',
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Select a Social tag and discover like contents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: socialTags.map((tag) {
                            final tagName = tag["rightText"]!;
                            final isFollowed = _isTagFollowed(tagName);
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SocialTagHorizontal(
                                categoryLabel: tag["categoryLabel"]!,
                                imagePath: tag["imagePath"]!,
                                rightText: tagName,
                                isFollowed: isFollowed,
                                onTap: () {
                                  _toggleTag(tagName);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Top Social Circles",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isLoadingSocialCommunities
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _socialCommunities.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'No social communities available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : CommunityListHorizontal(
                                    communities: _socialCommunities,
                                    initialJoinedCommunityIds: _followedCommunityIds,
                                  ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Select a Support tag and discover like contents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                      Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SocialTagHorizontal(
                          categoryLabel: "Emotional Healing",
                          imagePath:
                              "assets/icon/support-tags/emotionalHealing.svg",
                          rightText: "Emotional Healing",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Emotional Healing"),
                          onTap: () {
                            _toggleTag("Emotional Healing");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Anxiety & Stress",
                          imagePath:
                              "assets/icon/support-tags/anxietyAndStress.svg",
                          rightText: "Anxiety & Stress",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Anxiety & Stress"),
                          onTap: () {
                            _toggleTag("Anxiety & Stress");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Grief & Heartbreak",
                          imagePath:
                              "assets/icon/support-tags/griefAndHeartbreak.svg",
                          rightText: "Grief & Heartbreak",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Grief & Heartbreak"),
                          onTap: () {
                            _toggleTag("Grief & Heartbreak");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Work & Career",
                          imagePath:
                              "assets/icon/support-tags/workAndCareer.svg",
                          rightText: "Work & Career",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Work & Career"),
                          onTap: () {
                            _toggleTag("Work & Career");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Trauma",
                          imagePath:
                              "assets/icon/support-tags/traumaAndHealing.svg",
                          rightText: "Trauma",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Trauma"),
                          onTap: () {
                            _toggleTag("Trauma");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Family & Relations",
                          imagePath:
                              "assets/icon/support-tags/familyAndRelationship.svg",
                          rightText: "Family & Relations",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Family & Relations"),
                          onTap: () {
                            _toggleTag("Family & Relations");
                          },
                        ),
                        SocialTagHorizontal(
                          categoryLabel: "Self-Worth & Identity",
                          imagePath:
                              "assets/icon/support-tags/selfWorthAndIdentity.svg",
                          rightText: "Self-Worth & Identity",
                          iconShape: IconShape.square,
                          isFollowed: _isTagFollowed("Self-Worth & Identity"),
                          onTap: () {
                            _toggleTag("Self-Worth & Identity");
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Top Support Square by MHP's",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isLoadingSupportCommunities
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _supportCommunities.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'No support communities available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : CommunityListHorizontal(
                                    communities: _supportCommunities,
                                    initialJoinedCommunityIds: _followedCommunityIds,
                                  ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
