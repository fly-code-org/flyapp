import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/usecases/get_communities_by_type.dart';
import 'package:fly/features/interests/data/models/tag_mapping.dart';
import 'package:fly/features/interests/domain/entities/interests.dart';
import 'package:fly/features/interests/domain/usecases/save_interests.dart';
import 'package:fly/features/start_quiz/widgets/communities_grid.dart';
import 'package:fly/features/start_quiz/widgets/separator.dart';
import 'package:fly/features/start_quiz/widgets/social_tags.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class GetInterestScreen extends StatefulWidget {
  const GetInterestScreen({super.key});

  @override
  State<GetInterestScreen> createState() => _GetInterestScreenState();
}

class _GetInterestScreenState extends State<GetInterestScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Track selected tags (tag names)
  final Set<String> _selectedTags = {};

  // Track selected community IDs
  final Set<String> _selectedCommunities = {};

  // Loading state
  bool _isSaving = false;
  bool _isLoadingCommunities = false;
  
  // Communities from API
  List<Map<String, dynamic>> _communities = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
    print("GetInterestScreen role: $role");
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoadingCommunities = true;
    });

    try {
      final getCommunitiesByType = sl<GetCommunitiesByType>();
      final communities = await getCommunitiesByType.call('support');

      setState(() {
        _communities = communities.map((community) {
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
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Error loading communities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading communities: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCommunities = false;
        });
      }
    }
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTags.contains(tagName)) {
        _selectedTags.remove(tagName);
      } else {
        _selectedTags.add(tagName);
      }
    });
    print("Selected tags: $_selectedTags");
  }

  void _toggleCommunity(String communityId) {
    setState(() {
      if (_selectedCommunities.contains(communityId)) {
        _selectedCommunities.remove(communityId);
      } else {
        _selectedCommunities.add(communityId);
      }
    });
    print("Selected communities: $_selectedCommunities");
  }

  Future<void> _saveInterests() async {
    if (_selectedTags.isEmpty && _selectedCommunities.isEmpty) {
      // Allow saving even with no selections (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one tag or community'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Convert selected tags to Tag entities with IDs
      final tags = _selectedTags
          .map((tagName) {
            final tagId = TagMapping.getTagId(tagName);
            if (tagId == null) {
              print('Warning: Tag ID not found for "$tagName"');
              return null;
            }
            return Tag(tagId: tagId, name: tagName);
          })
          .whereType<Tag>()
          .toList();

      final interests = Interests(
        tags: tags,
        communities: _selectedCommunities.toList(),
      );

      final saveInterests = sl<SaveInterests>();
      await saveInterests(interests);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interests saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to explore screen
      Get.toNamed(AppRoutes.Explore);
    } catch (e) {
      print('Error saving interests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving interests: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _dragPosition > 0.3
                ? 50
                : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: 100,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _dragPosition = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Text(
                        "Which tags would you like to follow?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Separator(),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SocialTag(
                            categoryLabel: "Motivational",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/motivational.svg",
                            rightText: "Motivational",
                            isSelected: _selectedTags.contains("Motivational"),
                            onTap: () => _toggleTag("Motivational"),
                          ),
                          SocialTag(
                            categoryLabel: "Lifestyle",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/lifestyle.svg",
                            rightText: "Lifestyle",
                            isSelected: _selectedTags.contains("Lifestyle"),
                            onTap: () => _toggleTag("Lifestyle"),
                          ),
                          SocialTag(
                            categoryLabel: "Art & Creatives",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/artAndCreativity.svg",
                            rightText: "Art & Creatives",
                            isSelected: _selectedTags.contains(
                              "Art & Creatives",
                            ),
                            onTap: () => _toggleTag("Art & Creatives"),
                          ),
                          SocialTag(
                            categoryLabel: "Awwdorable",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/awdorable.svg",
                            rightText: "Awwdorable",
                            isSelected: _selectedTags.contains("Awwdorable"),
                            onTap: () => _toggleTag("Awwdorable"),
                          ),
                          SocialTag(
                            categoryLabel: "Fun & Humor",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/funAndHumor.svg",
                            rightText: "Fun & Humor",
                            isSelected: _selectedTags.contains("Fun & Humor"),
                            onTap: () => _toggleTag("Fun & Humor"),
                          ),
                          SocialTag(
                            categoryLabel: "Peace",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/peace.svg",
                            rightText: "Peace",
                            isSelected: _selectedTags.contains("Peace"),
                            onTap: () => _toggleTag("Peace"),
                          ),
                          SocialTag(
                            categoryLabel: "Words of Wisdom",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/wordsOfWisdom.svg",
                            rightText: "Words of Wisdom",
                            isSelected: _selectedTags.contains(
                              "Words of Wisdom",
                            ),
                            onTap: () => _toggleTag("Words of Wisdom"),
                          ),
                          SocialTag(
                            categoryLabel: "News & Insights",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/newsAndInsights.svg",
                            rightText: "News & Insights",
                            isSelected: _selectedTags.contains(
                              "News & Insights",
                            ),
                            onTap: () => _toggleTag("News & Insights"),
                          ),
                          SocialTag(
                            categoryLabel: "Movies & Shows",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/social-tags/moviesAndShows.svg",
                            rightText: "Movies & Shows",
                            isSelected: _selectedTags.contains(
                              "Movies & Shows",
                            ),
                            onTap: () => _toggleTag("Movies & Shows"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Separator(text: "Support tags"),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SocialTag(
                            categoryLabel: "Emotional Healing",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/emotionalHealing.svg",
                            rightText: "Emotional Healing",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains(
                              "Emotional Healing",
                            ),
                            onTap: () => _toggleTag("Emotional Healing"),
                          ),
                          SocialTag(
                            categoryLabel: "Anxiety & Stress",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/anxietyAndStress.svg",
                            rightText: "Anxiety & Stress",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains(
                              "Anxiety & Stress",
                            ),
                            onTap: () => _toggleTag("Anxiety & Stress"),
                          ),
                          SocialTag(
                            categoryLabel: "Grief & Heartbreak",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/griefAndHeartbreak.svg",
                            rightText: "Grief & Heartbreak",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains(
                              "Grief & Heartbreak",
                            ),
                            onTap: () => _toggleTag("Grief & Heartbreak"),
                          ),
                          SocialTag(
                            categoryLabel: "Work & Career",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/workAndCareer.svg",
                            rightText: "Work & Career",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains("Work & Career"),
                            onTap: () => _toggleTag("Work & Career"),
                          ),
                          SocialTag(
                            categoryLabel: "Trauma",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/traumaAndHealing.svg",
                            rightText: "Trauma",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains("Trauma"),
                            onTap: () => _toggleTag("Trauma"),
                          ),
                          SocialTag(
                            categoryLabel: "Family & Relations",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/familyAndRelationship.svg",
                            rightText: "Family & Relations",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains(
                              "Family & Relations",
                            ),
                            onTap: () => _toggleTag("Family & Relations"),
                          ),
                          SocialTag(
                            categoryLabel: "Self-Worth & Identity",
                            imageUrl:
                                "https://cdn.flyapp.in/assets/support-tags/selfWorthAndIdentity.svg",
                            rightText: "Self-Worth & Identity",
                            iconShape: IconShape.square,
                            isSelected: _selectedTags.contains(
                              "Self-Worth & Identity",
                            ),
                            onTap: () => _toggleTag("Self-Worth & Identity"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Separator(text: "Communities by MHPs✨"),
                      const SizedBox(height: 20),
                      _isLoadingCommunities
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _communities.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Text(
                                      'No communities available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              : CommunitiesGrid(
                                  communities: _communities,
                                  selectedCommunityIds: _selectedCommunities,
                                  onCommunityTap: _toggleCommunity,
                                ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: _isSaving ? "Saving..." : "Explore fly!",
                        onPressed: _isSaving
                            ? () {} // No-op when saving
                            : () {
                                _saveInterests();
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
