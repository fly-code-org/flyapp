import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/usecases/get_communities_by_type.dart';
import 'package:fly/features/explore/presentation/widgets/community_list_horizontal.dart';
import 'package:fly/features/explore/presentation/widgets/conversation_card.dart';
import 'package:fly/features/explore/presentation/widgets/search_bar.dart';
import 'package:fly/features/explore/presentation/widgets/social_tag_h.dart';
import 'package:fly/features/interests/data/models/tag_mapping.dart';
import 'package:fly/features/interests/domain/usecases/follow_tag.dart';
import 'package:fly/features/interests/domain/usecases/unfollow_tag.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_user_profile.dart';
import 'package:fly/features/user_profile/presentation/widgets/bottom_navbar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

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
  
  // Track followed tags by tag name (more reliable than ID since IDs overlap between social/support)
  final Set<String> _followedTagNames = {};

  @override
  void initState() {
    super.initState();
    _loadSocialCommunities();
    _loadSupportCommunities();
    _loadFollowedTags();
  }
  
  Future<void> _loadFollowedTags() async {
    try {
      print('🔍 [EXPLORE] Fetching user profile to get followed tags...');
      final getUserProfile = sl<GetUserProfile>();
      final userProfile = await getUserProfile.call();
      
      print('📦 [EXPLORE] User profile data: $userProfile');
      print('📦 [EXPLORE] Full followed_interests: ${userProfile['followed_interests']}');
      
      // Extract followed_interests from user profile
      if (userProfile.containsKey('followed_interests') && 
          userProfile['followed_interests'] is List) {
        final followedInterests = userProfile['followed_interests'] as List;
        
        setState(() {
          _followedTagNames.clear();
          for (var interest in followedInterests) {
            if (interest is Map<String, dynamic>) {
              // Use tag name for comparison (more reliable than ID)
              if (interest.containsKey('name') && interest['name'] is String) {
                final tagName = interest['name'] as String;
                // Normalize tag name (trim whitespace)
                final normalizedName = tagName.trim();
                _followedTagNames.add(normalizedName);
                print('   📌 Added followed tag: "$normalizedName" (original: "$tagName")');
              } else {
                print('   ⚠️ Interest missing name: $interest');
              }
            }
          }
        });
        
        print('✅ [EXPLORE] Loaded ${_followedTagNames.length} followed tags: $_followedTagNames');
      } else {
        print('ℹ️ [EXPLORE] No followed_interests found in user profile');
        setState(() {
          _followedTagNames.clear();
        });
      }
    } catch (e) {
      print('❌ [EXPLORE] Error loading followed tags: $e');
      // Don't show error to user, just use empty set
      setState(() {
        _followedTagNames.clear();
      });
    }
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
    final tagId = TagMapping.getTagId(tagName);
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

  Future<void> _loadSupportCommunities() async {
    setState(() {
      _isLoadingSupportCommunities = true;
    });

    try {
      final getCommunitiesByType = sl<GetCommunitiesByType>();
      final communities = await getCommunitiesByType.call('support');

      setState(() {
        _supportCommunities = communities.map((community) {
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
            // 🔙 Title Row
            Row(
              children: const [
                SizedBox(width: 20),
                Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
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
                    controller: TextEditingController(),
                    onChanged: (value) {
                      print("Searching: $value");
                    },
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),

            const SizedBox(height: 20),
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
