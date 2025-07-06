import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import 'onboarding.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
