// core/storage/user_verification_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserVerificationStorage {
  static const String _emailVerifiedKey = 'is_email_verified';
  static const String _phoneVerifiedKey = 'is_phone_verified';

  /// Save email verification status
  static Future<void> setEmailVerified(bool isVerified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailVerifiedKey, isVerified);
  }

  /// Get email verification status
  static Future<bool> isEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_emailVerifiedKey) ?? false;
  }

  /// Save phone verification status
  static Future<void> setPhoneVerified(bool isVerified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_phoneVerifiedKey, isVerified);
  }

  /// Get phone verification status
  static Future<bool> isPhoneVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_phoneVerifiedKey) ?? false;
  }

  /// Clear all verification status
  static Future<void> clearVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailVerifiedKey);
    await prefs.remove(_phoneVerifiedKey);
  }
}

