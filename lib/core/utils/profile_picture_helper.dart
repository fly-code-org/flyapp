// core/utils/profile_picture_helper.dart
// Helper utility for handling profile picture paths

class ProfilePictureHelper {
  /// Converts a profile picture path to the appropriate URL/asset path
  /// 
  /// - If path is a full URL (http/https), returns it as-is
  /// - If path starts with '/assets/', treat as CDN path (prepend CDN URL)
  ///   Note: Profile pictures stored as /assets/profile_*.svg are on CDN, not local assets
  /// - If path is relative (starts with '/'), prepend CDN URL
  /// - Returns empty string if path is null or empty
  static String getProfilePictureUrl(String? picturePath) {
    if (picturePath == null || picturePath.isEmpty) {
      return '';
    }

    final path = picturePath.trim();

    // If it's already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Profile pictures stored as /assets/profile_*.svg are on CDN, not local assets
    // So we prepend CDN URL for all paths starting with '/'
    if (path.startsWith('/')) {
      return 'https://cdn.flyapp.in$path';
    }

    // Otherwise, assume it's a relative path and prepend CDN
    return 'https://cdn.flyapp.in/$path';
  }

  /// Checks if a profile picture path is a local asset
  /// Note: Profile pictures stored as /assets/profile_*.svg are on CDN, not local assets
  /// This method returns false for profile pictures - they should be loaded from CDN
  static bool isLocalAsset(String? picturePath) {
    if (picturePath == null || picturePath.isEmpty) {
      return false;
    }
    final path = picturePath.trim();
    
    // Profile pictures like /assets/profile_*.svg are on CDN, not local
    if (path.startsWith('/assets/profile_')) {
      return false;
    }
    
    // Only return true for actual local asset paths (without leading /)
    return path.startsWith('assets/') && !path.startsWith('http');
  }

  /// Converts local asset path (e.g., '/assets/profile_1.svg') to Flutter asset path
  /// (e.g., 'assets/profile_1.svg') by removing the leading '/'
  static String getAssetPath(String? picturePath) {
    if (picturePath == null || picturePath.isEmpty) {
      return '';
    }

    final path = picturePath.trim();
    if (path.startsWith('/assets/')) {
      return path.substring(1); // Remove leading '/'
    }
    return path;
  }
}
