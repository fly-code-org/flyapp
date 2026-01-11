// data/utils/default_profile_picture.dart
// Utility for assigning random default profile pictures

import 'dart:math';

class DefaultProfilePicture {
  // Default profile pictures available on CDN
  // Using PNG/JPG instead of SVG to avoid parsing errors
  static const List<String> defaultProfileSVGs = [
    '/assets/profile_1.svg',
    '/assets/images/fly_logo.png', // Use PNG instead of SVG to avoid parsing errors
    '/assets/profile_3.svg',
    '/assets/profile_4.svg',
    '/assets/profile_5.svg',
    '/assets/profile_6.svg',
    '/assets/profile_7.svg',
    '/assets/profile_8.svg',
    '/assets/profile_9.svg',
    '/assets/profile_10.svg',
    '/assets/profile_11.svg',
    '/assets/profile_12.svg',
    '/assets/profile_13.svg',
    '/assets/profile_14.svg',
    '/assets/profile_15.svg',
    '/assets/profile_16.svg',
    '/assets/profile_17.svg',
    '/assets/profile_18.svg',
    '/assets/profile_19.svg',
    '/assets/profile_20.svg',
  ];

  /// Gets a random default profile picture based on user ID
  /// Uses userId as seed for Random to ensure consistency for the same user
  /// but appears random across different users
  /// 
  /// Returns the full CDN URL (e.g., 'https://cdn.flyapp.in/assets/profile_1.svg')
  static String getRandomProfilePicture(String userId) {
    // Use userId as seed for Random to ensure consistency for the same user
    final random = Random(userId.hashCode);
    final index = random.nextInt(defaultProfileSVGs.length);
    final svgPath = defaultProfileSVGs[index];
    // Return full CDN URL
    return 'https://cdn.flyapp.in$svgPath';
  }

  /// Gets the relative path (without CDN URL) for a user ID
  /// Useful for saving to backend (e.g., '/assets/profile_1.svg')
  static String getRandomProfilePicturePath(String userId) {
    final random = Random(userId.hashCode);
    final index = random.nextInt(defaultProfileSVGs.length);
    return defaultProfileSVGs[index];
  }
}
