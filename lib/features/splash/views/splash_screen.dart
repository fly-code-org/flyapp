import 'package:flutter/material.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/storage/onboarding_progress.dart';
import 'package:fly/core/services/onboarding_status_checker.dart';
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

    // No token, or expired: clear everything and start from onboarding.
    if (raw == null || raw.isEmpty || JwtDecoder.isExpired(raw)) {
      if (raw != null && raw.isNotEmpty) {
        await TokenStorage.deleteToken();
        ApiClient.clearAuthToken();
      }
      await OnboardingProgress.clear();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Get.off(() => const Onboarding());
      return;
    }

    // Valid token. A token alone isn't proof of completed registration — it is
    // issued at signup — so gate on the onboarding progress record.
    final progress = await OnboardingProgress.get();

    // No record: returning/logged-in user (or pre-feature account) -> Home.
    if (progress == null || progress['completed'] == true) {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.Home);
      return;
    }

    // Incomplete signup. Confirm with the backend in case the completion write
    // was lost; otherwise resume exactly where they left off.
    final role = (progress['role'] ?? 'user').toString();
    if (await OnboardingStatusChecker.isComplete(role)) {
      await OnboardingProgress.markComplete();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.Home);
      return;
    }

    final args = <String, dynamic>{
      'role': role,
      'email': (progress['email'] ?? '').toString(),
      'phone_number': (progress['phone_number'] ?? '').toString(),
    };
    final step = (progress['step'] ?? '').toString();
    if (!mounted) return;
    // Fall back to the first post-signup step if the step was never recorded.
    Get.offAllNamed(step.isEmpty ? AppRoutes.emailVerification : step,
        arguments: args);
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
