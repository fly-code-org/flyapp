import 'package:flutter/material.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final raw = await TokenStorage.getToken();

    if (raw != null && raw.isNotEmpty && !JwtDecoder.isExpired(raw)) {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.Home);
      return;
    }

    if (raw != null && raw.isNotEmpty) {
      await TokenStorage.deleteToken();
      ApiClient.clearAuthToken();
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Get.off(() => const Onboarding());
  }

  @override
  Widget build(BuildContext context) {
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
