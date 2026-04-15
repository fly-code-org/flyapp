import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration. All backend API calls (auth, post, nira, community, etc.)
/// use [backendApiBaseUrl] via [ApiClient.dio] — set API_BASE_URL in .env to override.
class AppConfig {
  /// Raw value from env (may be empty).
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// Base URL for all backend APIs (fly-be). Used by ApiClient; never empty.
  static const String _defaultBackendApiBaseUrl = 'https://api.flyapp.in';

  /// Single source of truth for backend API base URL. All features use this via ApiClient.dio.
  static String get backendApiBaseUrl =>
      apiBaseUrl.trim().isNotEmpty ? apiBaseUrl.trim() : _defaultBackendApiBaseUrl;

  static String get googleClientId {
    if (Platform.isIOS) {
      return dotenv.env['IOS_CLIENT_ID'] ?? '';
    } else {
      return dotenv.env['ANDROID_CLIENT_ID'] ?? '';
    }
  }

  /// Web OAuth client for Google Sign-In [serverClientId]. Same value as fly-be `GOOGLE_OAUTH_CLIENT_ID`.
  /// Falls back to `WEB_CLIENT_ID` if set (legacy).
  static String get googleWebClientId {
    final oauth = dotenv.env['GOOGLE_OAUTH_CLIENT_ID']?.trim() ?? '';
    if (oauth.isNotEmpty) return oauth;
    return dotenv.env['WEB_CLIENT_ID']?.trim() ?? '';
  }
}
