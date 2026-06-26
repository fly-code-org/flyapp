import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_visitor_connect_booking_tab.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/connect_booking_sticky_bar.dart';
import 'package:fly/features/mhp_profile/mhp_profile_strings.dart';
import 'package:fly/features/streak/presentation/streak_view_model.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_activities_section.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MhpProfileScreen extends StatefulWidget {
  const MhpProfileScreen({super.key});

  @override
  State<MhpProfileScreen> createState() => _MhpProfileScreenState();
}

class _BookSessionChip extends StatelessWidget {
  final VoidCallback onPressed;
  const _BookSessionChip({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_month_outlined, size: 16),
      label: const Text(
        'Book Session',
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF855DFC),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
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

  // Embedded connect booking support
  ValueNotifier<ConnectBookingBarState>? _connectBarNotifier;
  final _tabsRowKey = GlobalKey();
  ScrollController? _listScrollController;

  bool get _viewingOther =>
      _viewedUserId != null && _viewedUserId!.trim().isNotEmpty;

  void _onTabSelected(int index) {
    // Reset scroll to top so the new tab always starts from position 0
    // and avoids a jarring scroll-position clamp when content height changes.
    _listScrollController?.jumpTo(0);
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
              Icon(icon, color: isActive ? const Color(0xFF855DFC) : Colors.grey),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? const Color(0xFF855DFC) : Colors.grey[700],
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: isActive ? const Color(0xFF855DFC) : Colors.transparent,
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
        community = null;
      }

      final streaks = profileMap['streaks'];
      if (streaks is Map<String, dynamic> &&
          Get.isRegistered<StreakViewModel>()) {
        Get.find<StreakViewModel>().applyFromProfileMap(streaks);
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

  Widget _buildStreakBadge() {
    if (_viewingOther) {
      return _streakPill(_profile?.streakCount ?? 0);
    }
    if (!Get.isRegistered<StreakViewModel>()) {
      return _streakPill(_profile?.streakCount ?? 0);
    }
    final vm = Get.find<StreakViewModel>();
    return Obx(() {
      final count = vm.streakCount.value > 0
          ? vm.streakCount.value
          : (_profile?.streakCount ?? 0);
      return _streakPill(count);
    });
  }

  Widget _streakPill(int count) {
    if (count <= 0) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF855DFC).withOpacity(0.1),
          border: Border.all(color: const Color(0xFF855DFC), width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                size: 14, color: Color(0xFF855DFC)),
            const SizedBox(width: 4),
            Text(
              '$count Streak${count == 1 ? '' : 's'}',
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF855DFC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return MhpActivitiesSection(
            communityId: _community?.id ?? _profile?.communityId);
      case 1:
        if (_viewingOther && _loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        // embedded: true removes the inner SingleChildScrollView so the outer
        // ListView is the only scroll controller, eliminating the double-scroll trap.
        return MHPProfileEditScreen(
          initialWhoIAm: _profile?.whoIAm,
          initialHowICanHelp: _profile?.howICanHelp,
          initialWhatToExpect: _profile?.whatToExpect,
          readOnly: _viewingOther,
          averageRating: _profile?.averageRating ?? 0.0,
          ratingCount: _profile?.ratingCount ?? 0,
          specializations: _profile?.specializations ?? const [],
          feedbackItems: _profile?.feedbackItems ?? const [],
          embedded: true,
        );
      case 2:
        if (_viewingOther && _loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_viewingOther) {
          final uid = _viewedUserId?.trim();
          if (uid == null || uid.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load booking for this profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Lexend'),
                ),
              ),
            );
          }
          return MhpVisitorConnectBookingTab(
            mhpUserId: uid,
            mhpDisplayName: _profile?.userName,
            mhpPicturePath: _profile?.picturePath,
            barNotifier: _connectBarNotifier,
          );
        }
        // embedded: true removes RefreshIndicator/SingleChildScrollView.
        return ConnectTabContent(
          availableSlots: _profile?.availableSlots ?? [],
          appointments: _profile?.appointments ?? [],
          googleCalendarConnected: _profile?.googleCalendarConnected ?? false,
          googleCalendarStatus: _profile?.googleCalendarStatus,
          onSlotsUpdated: _loadProfile,
          embedded: true,
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
    if (_viewingOther) {
      _connectBarNotifier = ValueNotifier(const ConnectBookingBarState());
    }
    _loadProfile();
  }

  @override
  void dispose() {
    _connectBarNotifier?.dispose();
    super.dispose();
  }

  void _jumpToConnectTab() {
    _listScrollController?.jumpTo(0);
    setState(() => _selectedTab = 2);
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.black,

        // Visitor Connect bar is now an overlay inside the body Stack so it
        // doesn't reduce Scaffold body height and cause the sheet to jump up.
        bottomNavigationBar:
            _viewingOther ? null : BottomNavBar(currentIndex: 4),

        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background
            Positioned.fill(
              child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
            ),

            // White sheet — locked at 80 % height, single ListView scroll.
            DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.8,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                _listScrollController = scrollController;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main white card — unpositioned so Stack sizes to it.
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
                          if (!_loading && _profile != null)
                            _buildStreakBadge(),

                          const SizedBox(height: 60),

                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
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
                              yearsOfExperience: _profile!.yearsOfExperience,
                              certifiedMhp: _profile!.certifiedMhp,
                              degreePath: _profile!.degreePath,
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
                                    onPressed: () async {
                                      final updated = await Get.toNamed(
                                          AppRoutes.MhpEditProfile);
                                      if (updated == true) _loadProfile();
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                ],
                                if (_viewingOther) ...[
                                  _BookSessionChip(
                                      onPressed: _jumpToConnectTab),
                                  const SizedBox(width: 12),
                                ],
                                ShareProfile(
                                  onPressed: () async {
                                    String? shareId;
                                    if (_viewingOther) {
                                      shareId = _viewedUserId;
                                    } else {
                                      final token =
                                          await TokenStorage.getToken();
                                      shareId = JwtDecoder.getUserId(token);
                                    }
                                    if (!mounted) return;
                                    if (shareId != null &&
                                        shareId.isNotEmpty) {
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

                          if (!_loading && _error == null && _profile != null)
                            const SizedBox(height: 16),

                          // Single scroll for tabs + content. embedded: true on
                          // About/Connect removes their inner ScrollViews so
                          // this ListView is the only scroll controller.
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: EdgeInsets.zero,
                              children: [
                                // MHPSquare scrolls with content so the header
                                // above is as small as possible.
                                if (!_loading && _error == null) ...[
                                  MHPSquare(community: _community),
                                  const SizedBox(height: 16),
                                ],

                                Row(
                                  key: _tabsRowKey,
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
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height *
                                            0.45,
                                  ),
                                  child: _buildBody(),
                                ),
                              ],
                            ),
                          ),

                          // "Let's connect" bar pinned below the scroll area.
                          // Only rendered on Connect tab; jumpTo(0) on every tab
                          // switch means no jarring height-change jump.
                          if (_viewingOther &&
                              _selectedTab == 2 &&
                              _connectBarNotifier != null)
                            ValueListenableBuilder<ConnectBookingBarState>(
                              valueListenable: _connectBarNotifier!,
                              builder: (_, state, __) =>
                                  ConnectBookingStickyBar(state: state),
                            ),
                        ],
                      ),
                    ),

                    // Floating avatar — overlaps the top edge of the white card.
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
                );
              },
            ),

            // Badge, back button, and settings rendered AFTER the sheet so
            // they always appear on top of the floating avatar.
            if (_profile != null && _profile!.degreePath.isNotEmpty)
              Positioned(
                top: 52,
                left: _viewingOther ? 56 : 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/fly_logo.png',
                      height: 24,
                      width: 24,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.self_improvement,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Certified MHP',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
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

            if (!_viewingOther)
              Positioned(
                top: 50,
                right: 16,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icon/setting.svg',
                    width: 28,
                    height: 28,
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.MhpSettingsScreen);
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}
