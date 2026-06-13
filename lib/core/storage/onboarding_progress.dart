// core/storage/onboarding_progress.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks an in-progress signup/onboarding flow.
///
/// The backend issues a JWT at *signup* (before onboarding is finished), so a
/// valid token alone is not proof that registration is complete. This record
/// lets the splash screen resume a half-registered user at the exact step they
/// left off instead of dropping them onto Home.
///
/// Shape (JSON):
///   { "completed": bool, "step": <route>, "role": "user"|"mhp",
///     "email": <string>, "phone_number": <string> }
///
/// Semantics:
/// * `null`            -> no onboarding in progress (returning/logged-in user).
/// * `completed:true`  -> finished all mandatory steps; allowed into the app.
/// * `completed:false` -> resume at `step` with the saved context.
///
/// Mandatory completion gates:
/// * User: email verification + user profile created.
/// * MHP : email verification + MHP profile created + community created.
class OnboardingProgress {
  static const _storage = FlutterSecureStorage();
  static const String _key = 'onboarding_progress';

  /// Record the step the user is currently on (always marks incomplete).
  /// `step` is the GetX route name to resume to (e.g. AppRoutes.emailVerification).
  static Future<void> saveStep({
    required String step,
    required String role,
    String email = '',
    String phoneNumber = '',
  }) async {
    final data = <String, dynamic>{
      'completed': false,
      'step': step,
      'role': role,
      'email': email,
      'phone_number': phoneNumber,
    };
    await _storage.write(key: _key, value: jsonEncode(data));
  }

  /// Mark onboarding finished — the final mandatory step was reached, or the
  /// session belongs to a returning (already-onboarded) user who logged in.
  static Future<void> markComplete() async {
    await _storage.write(
      key: _key,
      value: jsonEncode(<String, dynamic>{'completed': true}),
    );
  }

  /// Returns the raw progress map, or null when nothing is stored / unreadable.
  static Future<Map<String, dynamic>?> get() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  static Future<bool> isComplete() async {
    final p = await get();
    return p != null && p['completed'] == true;
  }

  /// Remove the record entirely (logout / fresh start).
  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
