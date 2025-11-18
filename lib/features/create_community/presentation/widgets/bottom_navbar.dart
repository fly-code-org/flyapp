import 'package:flutter/material.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

// Example: replace this with your actual logic (controller or service)
// final bool isMhp = false // or Get.find<UserController>().isMhp

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF855DFC),
      unselectedItemColor: Colors.black,
      currentIndex: currentIndex,
      onTap: (index) {
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
            Get.offAllNamed(AppRoutes.mhpProfile);

            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset("assets/icon/navbar/home-filled.png"),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icon/navbar/explore-outlined.png"),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/images/nira_icon.png"),
          label: "Nira",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icon/navbar/notification-outlined.png"),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icon/navbar/profile-outlined.png"),
          label: "Profile",
        ),
      ],
    );
  }
}
