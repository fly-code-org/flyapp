// core/services/onboarding_status_checker.dart
import '../di/service_locator.dart';
import '../../features/profile_creation/domain/usecases/get_mhp_profile.dart';
import '../../features/profile_creation/domain/usecases/get_user_profile.dart';
import '../../features/community/domain/usecases/get_my_community.dart';

/// Confirms onboarding completion against the backend (the "hybrid" half of the
/// resume logic). Used on cold start when the *local* progress record says a
/// signup is still incomplete — e.g. the completion write was lost, or the user
/// finished on another install of the same account. Best-effort: any failure
/// returns false so we safely fall back to resuming the saved local step.
class OnboardingStatusChecker {
  /// Mandatory backend artifacts:
  /// * MHP : profile exists AND community exists.
  /// * User: profile exists.
  static Future<bool> isComplete(String role) async {
    final normalized = role.toLowerCase();
    try {
      if (normalized == 'mhp') {
        final hasProfile = await _mhpProfileExists();
        if (!hasProfile) return false;
        return await _communityExists();
      }
      return await _userProfileExists();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _mhpProfileExists() async {
    try {
      final map = await sl<GetMhpProfile>().call();
      // A created profile always carries a user_id; an empty/absent profile won't.
      final userId = map['user_id'];
      return userId != null && userId.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _communityExists() async {
    try {
      final community = await sl<GetMyCommunity>().call();
      return community != null;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _userProfileExists() async {
    try {
      final map = await sl<GetUserProfile>().call();
      final userId = map['user_id'] ?? map['username'];
      return userId != null && userId.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
