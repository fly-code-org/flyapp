import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/jwt_decoder.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';
import 'package:fly/features/profile_creation/data/datasources/user_profile_remote_data_source.dart';
import 'package:fly/features/streak/data/streak_patch_result.dart';
import 'package:fly/features/streak/presentation/streak_celebration_dialog.dart';
import 'package:fly/features/streak/presentation/streak_view_model.dart';
import 'package:fly/features/user_profile/presentation/controllers/user_profile_controller.dart';

/// Debounced streak PATCH for meaningful engagement (app open, scroll, posts, etc.).
class StreakEngagementService with WidgetsBindingObserver {
  StreakEngagementService._();
  static final StreakEngagementService instance = StreakEngagementService._();

  DateTime? _lastRequestAt;
  bool _initialized = false;

  void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _initialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      recordEngagement(reason: 'app_resumed');
    }
  }

  /// Call after meaningful interaction. Coalesces rapid calls (~25s).
  Future<void> recordEngagement({String reason = ''}) async {
    final now = DateTime.now();
    if (_lastRequestAt != null &&
        now.difference(_lastRequestAt!) < const Duration(seconds: 25)) {
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    _lastRequestAt = now;

    try {
      StreakPatchResult? result;
      if (JwtDecoder.isMhp(token)) {
        result = await sl<MhpProfileRemoteDataSource>().updateStreak();
      } else {
        result = await sl<UserProfileRemoteDataSource>().updateStreak();
      }
      if (result == null) return;

      if (Get.isRegistered<UserProfileController>()) {
        Get.find<UserProfileController>().applyStreakPatch(result);
      } else {
        if (!Get.isRegistered<StreakViewModel>()) {
          Get.put(StreakViewModel(), permanent: true);
        }
        Get.find<StreakViewModel>().applyFromPatch(result);
      }
      _maybeCelebrate(result);
    } catch (_) {
      // Non-blocking (network,404 MHP profile, etc.)
    }
  }

  void _maybeCelebrate(StreakPatchResult r) {
    final kind = r.delta.kind;
    if (kind == 'same_day') return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Get.context;
      if (ctx == null || !ctx.mounted) return;

      if (kind == 'increment') {
        final m = r.delta.scoreAfter;
        final isMilestone = {7, 14, 30, 100}.contains(m);
        showStreakCelebrationDialog(
          context: ctx,
          score: m,
          isMilestone: isMilestone,
          wasReset: false,
        );
      } else if (kind == 'reset') {
        showStreakCelebrationDialog(
          context: ctx,
          score: r.delta.scoreAfter,
          isMilestone: false,
          wasReset: true,
        );
      }
    });
  }
}
