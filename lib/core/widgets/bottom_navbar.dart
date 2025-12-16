// core/widgets/bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

/// Unified Bottom Navigation Bar component
/// Routes to the correct profile screen based on user role (user or mhp)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  /// Determines the correct profile route based on user's role from JWT token
  Future<String> _getProfileRoute() async {
    try {
      // Get token and check role
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final role = JwtDecoder.getRole(token);
        print('🔍 [BOTTOM_NAV] User role from JWT: $role');
        if (role?.toLowerCase() == 'mhp') {
          return AppRoutes.mhpProfile;
        }
      }
    } catch (e) {
      print('⚠️ [BOTTOM_NAV] Error getting role: $e');
    }
    // Default to user profile
    return AppRoutes.userProfile;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF855DFC),
      unselectedItemColor: Colors.black,
      currentIndex: currentIndex,
      onTap: (index) async {
        // Direct GetX navigation
        switch (index) {
          case 0:
            Get.offAllNamed(AppRoutes.Home);
            break;
          case 1:
            Get.offAllNamed(AppRoutes.Explore);
            break;
          case 2:
            Get.offAllNamed(AppRoutes.Nira);
            break;
          case 3:
            Get.offAllNamed(AppRoutes.NotificationScreen);
            break;
          case 4:
            // Determine profile route based on user role
            final profileRoute = await _getProfileRoute();
            print('🚀 [BOTTOM_NAV] Navigating to profile: $profileRoute');
            Get.offAllNamed(profileRoute);
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/images/nira_icon.png"),
          label: "Nira",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Notifications",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}

