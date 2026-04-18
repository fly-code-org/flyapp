import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Canonical legal URLs (override via `.env` for staging or before flyapp.in pages go live).
///
/// Optional keys (all optional):
/// - `FLY_PRIVACY_POLICY_URL`
/// - `FLY_TERMS_AND_CONDITIONS_URL`
/// - `FLY_COMMUNITY_GUIDELINES_URL`
class LegalUrls {
  LegalUrls._();

  /// Hosted privacy policy (update when the site page is live).
  static const String defaultPrivacyPolicy =
      'https://flyapp.in/privacy';

  /// Hosted terms & conditions.
  static const String defaultTermsAndConditions =
      'https://flyapp.in/terms';

  /// Platform Community Guidelines (Google Doc), referenced in legal docs.
  static const String defaultCommunityGuidelines =
      'https://docs.google.com/document/d/11dsAakOvQyrTaFyJB3_0iF9W3f5UMQjtqdXxF63dmX4/edit?usp=sharing';

  static String get privacyPolicy =>
      _fromEnv('FLY_PRIVACY_POLICY_URL', defaultPrivacyPolicy);

  static String get termsAndConditions =>
      _fromEnv('FLY_TERMS_AND_CONDITIONS_URL', defaultTermsAndConditions);

  static String get communityGuidelines =>
      _fromEnv('FLY_COMMUNITY_GUIDELINES_URL', defaultCommunityGuidelines);

  static String _fromEnv(String key, String fallback) {
    try {
      final v = dotenv.env[key];
      if (v != null && v.trim().isNotEmpty) {
        return v.trim();
      }
    } catch (_) {
      // dotenv not loaded (e.g. tests)
    }
    return fallback;
  }
}
