// core/utils/avatar_generator.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates a consistent avatar URL based on user identifier
/// Uses DiceBear API for beautiful, consistent avatars
class AvatarGenerator {
  // DiceBear API base URL
  static const String _diceBearBaseUrl = 'https://api.dicebear.com/7.x';
  
  // Available styles (you can choose based on your app's design)
  // Options: avataaars, bottts, identicon, initials, micah, openPeeps, personas, pixelArt
  static const String _defaultStyle = 'avataaars'; // Fun, colorful avatars
  
  /// Generate avatar URL from user ID or email
  /// Returns a consistent avatar URL for the same identifier
  static String generateAvatarUrl(String identifier, {String style = _defaultStyle}) {
    // Use identifier as seed for consistency
    final seed = identifier.trim().toLowerCase();
    
    // Build DiceBear API URL
    // Format: https://api.dicebear.com/7.x/{style}/png?seed={seed}
    // Using PNG instead of SVG for better Flutter compatibility
    return '$_diceBearBaseUrl/$style/png?seed=${Uri.encodeComponent(seed)}';
  }
  
  /// Generate avatar URL from user ID (preferred for consistency)
  static String generateFromUserId(String userId) {
    return generateAvatarUrl(userId, style: _defaultStyle);
  }
  
  /// Generate avatar URL from email
  static String generateFromEmail(String email) {
    return generateAvatarUrl(email, style: _defaultStyle);
  }
  
  /// Generate avatar URL with custom style
  /// Available styles: avataaars, bottts, identicon, initials, micah, openPeeps, personas, pixelArt
  static String generateWithStyle(String identifier, String style) {
    return generateAvatarUrl(identifier, style: style);
  }
  
  /// Get a random but consistent avatar for a user
  /// Uses hash of identifier to ensure consistency
  static String getConsistentAvatar(String identifier) {
    // Create a hash of the identifier for consistent selection
    final bytes = utf8.encode(identifier);
    final digest = sha256.convert(bytes);
    final hash = digest.toString();
    
    // Use first 8 characters of hash as seed
    final seed = hash.substring(0, 8);
    
    return '$_diceBearBaseUrl/$_defaultStyle/svg?seed=$seed';
  }
}

