import 'package:flutter/material.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

// Example: replace this with your actual logic (controller or service)
final bool isMhp = true; // or Get.find<UserController>().isMhp

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
            // 👇 Check if user is MHP
            if (isMhp) {
              Get.offAllNamed(AppRoutes.mhpProfile);
            } else {
              Get.offAllNamed(AppRoutes.Profile);
            }
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
