import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Single analytics wrapper over PostHog.
///
/// Rules for this mental-health app:
///  - Never log message/journal/post content.
///  - Never log email, phone, or MHP names — only opaque UUIDs.
///  - All callers use the typed static methods below; no direct PostHog calls elsewhere.
class AnalyticsService {
  AnalyticsService._();

  static bool _ready = false;

  // ─── Initialisation ───────────────────────────────────────────────────────

  static Future<void> initialize({
    required String apiKey,
    required String host,
  }) async {
    if (apiKey.isEmpty || apiKey.startsWith('phc_REPLACE')) {
      debugPrint('⚠️ [Analytics] PostHog API key not configured — events will be dropped.');
      return;
    }
    final config = PostHogConfig(apiKey)
      ..host = host
      ..debug = kDebugMode
      ..captureApplicationLifecycleEvents = true
      ..sessionReplay = true
      ..sessionReplayConfig = (PostHogSessionReplayConfig()
        ..maskAllImages = false
        ..maskAllTexts = true);   // mask text inputs (OTP, passwords, etc.)
    await Posthog().setup(config);
    _ready = true;
    debugPrint('✅ [Analytics] PostHog ready (host: $host)');
  }

  // ─── Identity ─────────────────────────────────────────────────────────────

  /// Call after successful login/signup. [userId] is the backend UUID.
  static void identify({required String userId, required String role}) {
    if (!_ready) return;
    Posthog().identify(
      userId: userId,
      userProperties: {'role': role},
    );
  }

  /// Call on logout.
  static void reset() {
    if (!_ready) return;
    Posthog().reset();
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  static void signupStarted({required String role, required String method}) =>
      _track('signup_started', {'role': role, 'method': method});

  static void signupCompleted({
    required String role,
    required String method,
    required int durationSeconds,
  }) =>
      _track('signup_completed', {
        'role': role,
        'method': method,
        'duration_seconds': durationSeconds,
      });

  static void loginCompleted({required String role, required String method}) =>
      _track('login_completed', {'role': role, 'method': method});

  static void otpRequested({required String channel}) =>
      _track('otp_requested', {'channel': channel}); // "email" | "sms"

  static void otpVerified({required String channel}) =>
      _track('otp_verified', {'channel': channel});

  static void otpFailed({required String channel, required int attemptNumber}) =>
      _track('otp_failed', {'channel': channel, 'attempt_number': attemptNumber});

  static void otpResent({required String channel}) =>
      _track('otp_resent', {'channel': channel});

  static void profileStepCompleted({required String step, required String role}) =>
      _track('profile_step_completed', {'step': step, 'role': role});

  static void onboardingCompleted({
    required String role,
    required int durationSeconds,
  }) =>
      _track('onboarding_completed', {
        'role': role,
        'duration_seconds': durationSeconds,
      });

  // ─── Home / Feed ──────────────────────────────────────────────────────────

  static void homeOpened({required String role}) =>
      _track('home_opened', {'role': role});

  static void tabSwitched({required String from, required String to}) =>
      _track('tab_switched', {'from': from, 'to': to});

  static void feedFilterChanged({
    required String filter,
    required String tab,
  }) =>
      _track('feed_filter_changed', {'filter': filter, 'tab': tab});

  // ─── Posts ────────────────────────────────────────────────────────────────

  static void postCreated({
    required bool hasImage,
    required bool hasVideo,
    required bool hasPoll,
    required String tagType,
  }) =>
      _track('post_created', {
        'has_image': hasImage,
        'has_video': hasVideo,
        'has_poll': hasPoll,
        'tag_type': tagType,
      });

  static void postLiked() => _track('post_liked', {});

  static void postUnliked() => _track('post_unliked', {});

  static void postShared() => _track('post_shared', {});

  static void commentCreated() => _track('comment_created', {});

  // ─── Journal ──────────────────────────────────────────────────────────────

  static void journalOpened() => _track('journal_opened', {});

  /// [hasImage]: whether an image was attached. Never log content.
  static void journalCreated({required bool hasImage}) =>
      _track('journal_created', {'has_image': hasImage});

  static void journalUpdated() => _track('journal_updated', {});

  // ─── Nira (AI chat) ───────────────────────────────────────────────────────

  static void niraSessionStarted() => _track('nira_session_started', {});

  /// Count only — never content.
  static void niraMessageSent() => _track('nira_message_sent', {});

  static void niraSessionEnded({
    required int messageCount,
    required int durationSeconds,
  }) =>
      _track('nira_session_ended', {
        'message_count': messageCount,
        'duration_seconds': durationSeconds,
      });

  // ─── Connect / Therapy ────────────────────────────────────────────────────

  static void upgradeTapped({required String sourceScreen}) =>
      _track('upgrade_tapped', {'source_screen': sourceScreen});

  static void mhpProfileViewed() => _track('mhp_profile_viewed', {});

  static void sessionBookingStarted() =>
      _track('session_booking_started', {});

  static void sessionBookingAbandoned() =>
      _track('session_booking_abandoned', {});

  static void paymentInitiated({
    required int amountInr,
    required String orderType,
  }) =>
      _track('payment_initiated', {
        'amount_inr': amountInr,
        'order_type': orderType,
      });

  static void paymentCompleted({
    required int amountInr,
    required String orderType,
  }) =>
      _track('payment_completed', {
        'amount_inr': amountInr,
        'order_type': orderType,
      });

  static void paymentFailed({required String reason}) =>
      _track('payment_failed', {'reason': reason});

  // ─── Friction / Errors ────────────────────────────────────────────────────

  static void apiErrorShown({
    required String endpoint,
    required int statusCode,
  }) =>
      _track('api_error_shown', {
        'endpoint': endpoint,
        'status_code': statusCode,
      });

  static void retryTapped({required String screen}) =>
      _track('retry_tapped', {'screen': screen});

  static void formErrorShown({
    required String screen,
    required String field,
  }) =>
      _track('form_error_shown', {'screen': screen, 'field': field});

  // ─── Internal ─────────────────────────────────────────────────────────────

  static void _track(String event, Map<String, Object> properties) {
    if (!_ready) return;
    Posthog().capture(eventName: event, properties: properties);
  }
}
