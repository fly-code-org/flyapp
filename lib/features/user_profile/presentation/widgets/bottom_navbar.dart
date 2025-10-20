import 'package:flutter/material.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

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
        // 👇 Direct GetX navigation
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
            Get.offAllNamed("/notifications");
            break;
          case 4:
            Get.offAllNamed(AppRoutes.userProfile);
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
          // Nira chatbot icon
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
