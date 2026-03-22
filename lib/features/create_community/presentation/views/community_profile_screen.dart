import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/share_service.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/features/community/domain/usecases/get_community_by_id.dart';
import 'package:fly/features/community/domain/usecases/get_my_community.dart';
import 'package:fly/features/interests/data/models/tag_icon_mapping.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/features/create_community/presentation/widgets/community_menu.dart';
import 'package:fly/features/create_community/presentation/widgets/community_posts_tabs.dart';
import 'package:fly/features/create_community/presentation/widgets/community_profile_card.dart';
import 'package:fly/features/create_community/presentation/widgets/custom_tab_with_media.dart';
import 'package:fly/features/create_community/presentation/widgets/edit_community_button.dart';
import 'package:fly/features/create_community/presentation/widgets/invite_members.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class CommunitySupportProfile extends StatefulWidget {
  const CommunitySupportProfile({super.key});

  @override
  State<CommunitySupportProfile> createState() =>
      _CommunitySupportProfileState();
}

class _CommunitySupportProfileState extends State<CommunitySupportProfile> {
  Community? _community;
  bool _loading = true;
  String? _error;
  String _tagIconPath = '';
  bool _isOwner = false;
  String? _passedCommunityId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _passedCommunityId = args['communityId'] as String?;
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Community? community;
      if (_passedCommunityId != null && _passedCommunityId!.isNotEmpty) {
        community = await sl<GetCommunityById>().call(_passedCommunityId!);
      } else {
        community = await sl<GetMyCommunity>().call();
      }

      if (!mounted) return;
      if (community == null) {
        setState(() {
          _community = null;
          _loading = false;
        });
        return;
      }

      _tagIconPath = TagIconMapping.getTagIconPathById(community.tagId);

      final token = await TokenStorage.getToken();
      final currentUserId = JwtDecoder.getUserId(token) ?? '';
      final isOwner = currentUserId.isNotEmpty && community.createdBy == currentUserId;

      setState(() {
        _community = community;
        _tagIconPath = _tagIconPath;
        _isOwner = isOwner;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => popOrGoHome(context),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const CommunityMenuSheet(),
                );
              },
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.87,
            minChildSize: 0.87,
            maxChildSize: 0.87,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (_) => true,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF855DFC)))
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error!, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _loadCommunity,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _community == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('No community yet', style: TextStyle(fontFamily: 'Lexend')),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => Get.toNamed(AppRoutes.CreateSupportCommunity),
                                        child: const Text('Create community'),
                                      ),
                                    ],
                                  ),
                                )
                              : DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 15),
                                      CommunityProfileCard(
                                        communityType: 'support',
                                        title: _community!.name,
                                        members: _community!.members?.length ?? 0,
                                        description: _community!.description,
                                        tagIconPath: _tagIconPath.isNotEmpty
                                            ? _tagIconPath
                                            : 'assets/icon/social-tags/wordsOfWisdom.svg',
                                        profileImagePath: 'assets/images/community_demo.png',
                                        profileImageUrl: _community!.logoPath.isNotEmpty
                                            ? ProfilePictureHelper.getProfilePictureUrl(_community!.logoPath)
                                            : null,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if (_isOwner)
                                            EditCommunityButton(
                                              onPressed: () async {
                                                await Get.toNamed(AppRoutes.EditCommunity, arguments: {'community': _community});
                                                if (mounted) _loadCommunity();
                                              },
                                            ),
                                          if (_isOwner) const SizedBox(width: 35),
                                          InviteMembersButton(
                                            onPressed: () {
                                              ShareService.shareCommunity(
                                                communityId: _community!.id,
                                                communityName: _community!.name,
                                                context: context,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40),
                                      CustomTabWithMedia(
                                        onMediaPressed: () {},
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: CommunityPostsTabs(communityId: _community!.id),
                                      ),
                                    ],
                                  ),
                                ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}
