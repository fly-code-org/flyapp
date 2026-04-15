import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/profile_creation/domain/usecases/link_mhp_google_calendar.dart';

/// Persists a Google Sign-In `serverAuthCode` when MHP profile is not ready yet (Google signup),
/// then [consumeAndLinkIfPresent] runs after `createProfile` succeeds.
class PendingMhpGoogleCalendarCode {
  PendingMhpGoogleCalendarCode._();

  static const _key = 'pending_mhp_google_server_auth_code';
  static const _storage = FlutterSecureStorage();

  static Future<void> save(String code) async {
    final t = code.trim();
    if (t.isEmpty) return;
    await _storage.write(key: _key, value: t);
  }

  static Future<String?> read() async => _storage.read(key: _key);

  static Future<void> clear() async => _storage.delete(key: _key);

  /// Calls [link] with a stored code if any; clears storage only after a successful link.
  /// Returns whether a link was attempted and succeeded.
  static Future<bool> consumeAndLinkIfPresent(LinkMhpGoogleCalendar link) async {
    final code = await read();
    if (code == null || code.isEmpty) return false;
    try {
      await link(code);
      await clear();
      return true;
    } catch (_) {
      // Keep code for a later retry (e.g. profile not ready or transient error).
      return false;
    }
  }
}
