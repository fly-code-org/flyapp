import 'dart:io' show Platform;

import 'package:google_sign_in/google_sign_in.dart';

import 'config.dart';

/// Google Sign-In configured for Fly login and for MHP Calendar / Meet (server auth code).
///
/// `GOOGLE_OAUTH_CLIENT_ID` must be a **Web application** OAuth client from the **same
/// Google Cloud project** as [AppConfig.googleClientId] (iOS/Android). If the project
/// number prefix differs (e.g. 228… vs 809…), iOS will throw `invalid_audience`.
GoogleSignIn createFlyGoogleSignIn() {
  final web = AppConfig.googleWebClientId.trim();
  final native = AppConfig.googleClientId.trim();
  return GoogleSignIn(
    scopes: const [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar.events',
    ],
    clientId: native.isEmpty ? null : native,
    serverClientId: web.isEmpty ? null : web,
    forceCodeForRefreshToken: Platform.isAndroid,
  );
}
