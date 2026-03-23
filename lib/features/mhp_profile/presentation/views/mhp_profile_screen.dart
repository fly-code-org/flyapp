import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/core/services/share_service.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/features/mhp_profile/data/models/mhp_profile_display.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/edit_profile_button.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_info_card.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_squares.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/profile_card.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/share_profile.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/features/community/domain/usecases/get_community_by_id.dart';
import 'package:fly/features/community/domain/usecases/get_my_community.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_mhp_profile.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_mhp_profile_by_user_id.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/about_screen.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/connect_tab_content.dart';
import 'package:fly/features/mhp_profile/mhp_profile_strings.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_activities_section.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MhpProfileScreen extends StatefulWidget {
  const MhpProfileScreen({super.key});

  @override
  State<MhpProfileScreen> createState() => _MhpProfileScreenState();
}

class _MhpProfileScreenState extends State<MhpProfileScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  MhpProfileDisplay? _profile;
  Community? _community;
  bool _loading = true;
  String? _error;
  /// When non-null, we are viewing another MHP (Explore / deep link).
  String? _viewedUserId;

  bool get _viewingOther =>
      _viewedUserId != null && _viewedUserId!.trim().isNotEmpty;

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? Color(0xFF855DFC) : Colors.grey),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Color(0xFF855DFC) : Colors.grey[700],
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: isActive ? Color(0xFF855DFC) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await TokenStorage.getToken();
      final selfId = JwtDecoder.getUserId(token);
      if (_viewedUserId != null &&
          selfId != null &&
          _viewedUserId == selfId) {
        if (mounted) {
          setState(() => _viewedUserId = null);
        }
      }
      final viewed = _viewedUserId;
      if (viewed != null && viewed.trim().isNotEmpty) {
        final getById = sl<GetMhpProfileByUserId>();
        final profileMap = await getById.call(viewed.trim());
        Community? community;
        final cidRaw = profileMap['community_id'];
        String? cidStr;
        if (cidRaw is String && cidRaw.isNotEmpty) {
          cidStr = cidRaw;
        }
        if (cidStr != null && cidStr.isNotEmpty) {
          try {
            community = await sl<GetCommunityById>().call(cidStr);
          } catch (_) {
            community = null;
          }
        }
        final dn = (profileMap['display_name'] as String?)?.trim();
        final fallbackName = dn != null && dn.isNotEmpty ? dn : 'MHP';
        if (!mounted) return;
        setState(() {
          _profile =
              MhpProfileDisplay.fromMap(profileMap, userName: fallbackName);
          _community = community;
          _loading = false;
        });
        return;
      }

      final userName = JwtDecoder.getUserName(token) ?? '';
      final getMhpProfile = sl<GetMhpProfile>();
      final getMyCommunity = sl<GetMyCommunity>();

      final profileMap = await getMhpProfile.call();
      Community? community;
      try {
        community = await getMyCommunity.call();
      } catch (_) {
        // MHP may not have created a community yet
        community = null;
      }

      if (!mounted) return;
      setState(() {
        _profile = MhpProfileDisplay.fromMap(profileMap, userName: userName);
        _community = community;
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

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return MhpActivitiesSection(communityId: _community?.id ?? _profile?.communityId);
      case 1:
        if (_viewingOther && _loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return MHPProfileEditScreen(
          initialWhoIAm: _profile?.whoIAm,
          initialHowICanHelp: _profile?.howICanHelp,
          initialWhatToExpect: _profile?.whatToExpect,
          readOnly: _viewingOther,
        );
      case 2:
        if (_viewingOther) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Availability is managed on this professional’s account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Lexend'),
              ),
            ),
          );
        }
        return ConnectTabContent(
          availableSlots: _profile?.availableSlots ?? [],
          appointments: _profile?.appointments ?? [],
          onSlotsUpdated: _loadProfile,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _viewedUserId = args?['userId'] as String?;
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
      backgroundColor: Colors.black,

      // Bottom nav bar
      bottomNavigationBar:
          _viewingOther ? null : BottomNavBar(currentIndex: 4),

      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),

          if (_viewingOther)
            Positioned(
              top: 50,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => popOrGoHome(context),
              ),
            ),

          // Settings (hamburger menu)
          if (!_viewingOther)
            Positioned(
              top: 50,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.settings_suggest_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.UserSettingsScreen);
                },
              ),
            ),

          // Draggable white sheet
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // setState(() {
                  //   _dragPosition = notification.extent;
                  // });
                  return true;
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // White sheet: fixed header above "MHP's Square", rest scrollable
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else if (_profile != null) ...[
                            UserInfo(
                              userName: _profile!.userName,
                              bio: _profile!.bio,
                              location: _profile!.locationString,
                              yearsOfExp: _profile!.memberSinceString,
                            ),
                          ],
                          if (!_loading && _error == null && _profile != null)
                            const SizedBox(height: 20),
                          if (!_loading && _error == null && _profile != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (!_viewingOther) ...[
                                  EditProfileButton(
                                    onPressed: () {
                                      Get.toNamed('/edit-community');
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                ],
                                ShareProfile(
                                  onPressed: () async {
                                    String? shareId;
                                    if (_viewingOther) {
                                      shareId = _viewedUserId;
                                    } else {
                                      final token = await TokenStorage.getToken();
                                      shareId = JwtDecoder.getUserId(token);
                                    }
                                    if (!mounted) return;
                                    if (shareId != null && shareId.isNotEmpty) {
                                      ShareService.shareProfile(
                                        profileId: shareId,
                                        profileName: _profile?.userName,
                                        context: context,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          // Scrollable: from "MHP's Square" row downward
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: EdgeInsets.zero,
                              children: [
                                MHPSquare(community: _community),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTabItem(
                                      "Activities",
                                      Icons.dashboard_outlined,
                                      0,
                                    ),
                                    Row(
                                      children: [
                                        _buildTabItem(
                                          "About",
                                          Icons.verified_user_outlined,
                                          1,
                                        ),
                                        const SizedBox(width: 16),
                                        _buildTabItem(
                                          mhpProfileThirdTabTitle(
                                            viewingOther: _viewingOther,
                                          ),
                                          Icons.calendar_month_outlined,
                                          2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 600, child: _buildBody()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating avatar
                    Positioned(
                      top: -60,
                      left: 16,
                      child: ProfileAvatar(
                        imagePath: _profile != null &&
                                _profile!.picturePath.isNotEmpty
                            ? ProfilePictureHelper.getProfilePictureUrl(
                                _profile!.picturePath)
                            : 'assets/images/communitydp.png',
                        size: 120,
                        showEditIcon: false,
                      ),
                    ),
                  ],
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
