// core/services/share_service.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Shares a post with the native share dialog
  /// 
  /// [postId] - The ID of the post to share
  /// [postText] - The text content of the post (optional)
  /// [username] - The username of the post author (optional)
  /// [context] - BuildContext for getting share position (required on iPad)
  /// 
  /// Returns true if share was successful, false otherwise
  static Future<bool> sharePost({
    required String postId,
    String? postText,
    String? username,
    BuildContext? context,
  }) async {
    try {
      // Generate app deep link (custom URL scheme)
      // Using only flyapp:// scheme as requested
      final appLink = 'flyapp://post/$postId';
      
      // Build share text with the app link
      String shareText = '';
      
      if (username != null && username.isNotEmpty) {
        shareText = 'Check out this post by @$username';
      } else {
        shareText = 'Check out this post';
      }
      
      if (postText != null && postText.isNotEmpty) {
        // Truncate post text if too long (max 100 chars for preview)
        final truncatedText = postText.length > 100 
            ? '${postText.substring(0, 100)}...' 
            : postText;
        shareText += ':\n\n"$truncatedText"';
      }
      
      // Add app link on its own line
      // Note: Custom URL schemes (flyapp://) are not clickable in WhatsApp
      // but will work when tapped in Safari, Notes, Messages, or other apps
      shareText += '\n\n$appLink';
      
      // Ensure share text is not empty
      if (shareText.trim().isEmpty) {
        print('⚠️ [SHARE SERVICE] Share text is empty, using default');
        shareText = 'Check out this post on Fly:\n\n$appLink';
      }
      
      print('📤 [SHARE SERVICE] Sharing link: $appLink');
      
      print('📤 [SHARE SERVICE] Sharing text: ${shareText.substring(0, shareText.length > 100 ? 100 : shareText.length)}...');
      
      // Get share position origin for iPad (required for popover positioning)
      Rect? sharePositionOrigin;
      if (context != null) {
        try {
          final RenderBox? box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final Offset position = box.localToGlobal(Offset.zero);
            final Size size = box.size;
            sharePositionOrigin = Rect.fromLTWH(
              position.dx,
              position.dy,
              size.width,
              size.height,
            );
            print('📍 [SHARE SERVICE] Share position: ${position.dx}, ${position.dy}, ${size.width}x${size.height}');
          }
        } catch (e) {
          print('⚠️ [SHARE SERVICE] Could not get share position: $e');
        }
      }
      
      // Share using native share dialog
      // On iPad, sharePositionOrigin is required for popover positioning
      try {
        final result = await Share.share(
          shareText,
          subject: 'Check out this post on Fly',
          sharePositionOrigin: sharePositionOrigin,
        );
        print('✅ [SHARE SERVICE] Share dialog opened successfully');
        print('   - Result status: ${result.status}');
        // Consider both success and dismissed as successful (user interaction happened)
        return result.status == ShareResultStatus.success || 
               result.status == ShareResultStatus.dismissed;
      } catch (subjectError) {
        // If sharing with subject fails, try without subject
        print('⚠️ [SHARE SERVICE] Share with subject failed, trying without subject: $subjectError');
        try {
          final result = await Share.share(
            shareText,
            sharePositionOrigin: sharePositionOrigin,
          );
          print('✅ [SHARE SERVICE] Share dialog opened successfully (without subject)');
          print('   - Result status: ${result.status}');
          return result.status == ShareResultStatus.success || 
                 result.status == ShareResultStatus.dismissed;
        } catch (e) {
          // Re-throw if both attempts fail
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      print('❌ [SHARE SERVICE] Error sharing post: $e');
      print('❌ [SHARE SERVICE] Error type: ${e.runtimeType}');
      print('❌ [SHARE SERVICE] Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Generates a deep link URL for a post
  static String generatePostDeepLink(String postId) {
    // Prefer Universal Link for better compatibility
    return 'https://flyapp.in/post/$postId';
  }
  
  /// Generates a custom URL scheme link for a post (fallback)
  static String generatePostCustomSchemeLink(String postId) {
    return 'flyapp://post/$postId';
  }
}
