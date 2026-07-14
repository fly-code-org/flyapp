// core/storage/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _tokenKey = 'auth_token';
  static const String _authProviderKey = 'auth_provider';

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _authProviderKey);
  }

  /// Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save auth provider (e.g., 'google' or 'email')
  static Future<void> saveAuthProvider(String provider) async {
    await _storage.write(key: _authProviderKey, value: provider);
  }

  /// Retrieve auth provider
  static Future<String?> getAuthProvider() async {
    return await _storage.read(key: _authProviderKey);
  }

  /// Check if user signed up via Google
  static Future<bool> isGoogleUser() async {
    final provider = await getAuthProvider();
    return provider == 'google';
  }
}

