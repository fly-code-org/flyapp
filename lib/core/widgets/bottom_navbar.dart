// core/widgets/bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/features/notifications/controller/notification_controller.dart';
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
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final role = JwtDecoder.getRole(token);
        if (role?.toLowerCase() == 'mhp') {
          return AppRoutes.mhpProfile;
        }
      }
    } catch (_) {}
    return AppRoutes.userProfile;
  }

  NotificationController? get _notifController {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return null;
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
            final profileRoute = await _getProfileRoute();
            Get.offAllNamed(profileRoute);
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset('assets/images/nira_icon.png'),
          ),
          label: 'Nira',
        ),
        BottomNavigationBarItem(
          icon: Obx(() {
            final controller = _notifController;
            final count = controller?.unreadCount.value ?? 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
