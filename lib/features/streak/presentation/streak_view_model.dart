import 'package:get/get.dart';
import '../data/streak_patch_result.dart';

/// Shared reactive streak state for UI (user home + MHP explore chip).
class StreakViewModel extends GetxController {
  final streakCount = 0.obs;
  final lastEngagedAt = Rxn<DateTime>();
  final freeStreakUses = 0.obs;
  final paidStreakCredits = 0.obs;

  /// Reads score from API map (supports legacy `sore` typo).
  static int readScoreFromMap(Map<String, dynamic> streaks) {
    final s = streaks['score'];
    if (s is int) return s;
    if (s is num) return s.toInt();
    final legacy = streaks['sore'];
    if (legacy is int) return legacy;
    if (legacy is num) return legacy.toInt();
    return 0;
  }

  void applyFromPatch(StreakPatchResult r) {
    applyFromProfileMap({
      'score': r.streaks.score,
      if (r.streaks.lastEngagedAt != null)
        'last_engaged_at': r.streaks.lastEngagedAt!.toUtc().toIso8601String(),
      'free_streak_uses': r.streaks.freeStreakUses,
      'paid_streak_credits': r.streaks.paidStreakCredits,
    });
  }

  void applyFromProfileMap(Map<String, dynamic>? streaks) {
    if (streaks == null) {
      streakCount.value = 0;
      lastEngagedAt.value = null;
      return;
    }
    streakCount.value = readScoreFromMap(streaks);
    final raw = streaks['last_engaged_at'];
    if (raw is String && raw.isNotEmpty) {
      lastEngagedAt.value = DateTime.tryParse(raw);
    } else {
      lastEngagedAt.value = null;
    }
    freeStreakUses.value = (streaks['free_streak_uses'] as num?)?.toInt() ?? 0;
    paidStreakCredits.value =
        (streaks['paid_streak_credits'] as num?)?.toInt() ?? 0;
  }

}
