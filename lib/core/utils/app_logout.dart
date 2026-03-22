import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fly/core/di/service_locator.dart' as di;
import 'package:fly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fly/routes/app_routes.dart';

/// Confirms with the user, clears session (token, API client, caches), and
/// navigates to onboarding (unauthenticated entry).
Future<void> confirmAndLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;

  await di.sl<AuthController>().logout();
  Get.offAllNamed(AppRoutes.onboarding);
}
