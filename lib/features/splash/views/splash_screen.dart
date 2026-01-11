import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import 'onboarding.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller lazily
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }

    // Navigate after delay
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(() => const Onboarding());
    });

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/fly_logo.png'),
          height: 100,
        ),
      ),
    );
  }
}
