// core/utils/image_processor.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Resize image to specified dimensions while maintaining aspect ratio
  /// Returns the resized image as Uint8List
  static Future<Uint8List?> resizeImage({
    required File imageFile,
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      print('🖼️ [IMAGE PROCESSOR] Starting image resize...');
      print('   - File path: ${imageFile.path}');
      print('   - Max width: $maxWidth');
      print('   - Max height: $maxHeight');

      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      print('✅ [IMAGE PROCESSOR] Image read: ${imageBytes.length} bytes');

      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        print('❌ [IMAGE PROCESSOR] Failed to decode image');
        return null;
      }

      print('✅ [IMAGE PROCESSOR] Image decoded:');
      print('   - Original width: ${originalImage.width}');
      print('   - Original height: ${originalImage.height}');

      // Calculate new dimensions
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (maxWidth != null && originalImage.width > maxWidth) {
        final ratio = maxWidth / originalImage.width;
        newWidth = maxWidth;
        newHeight = (originalImage.height * ratio).round();
      }

      if (maxHeight != null && newHeight > maxHeight) {
        final ratio = maxHeight / newHeight;
        newWidth = (newWidth * ratio).round();
        newHeight = maxHeight;
      }

      // Only resize if dimensions changed
      img.Image resizedImage;
      if (newWidth != originalImage.width ||
          newHeight != originalImage.height) {
        print('🔄 [IMAGE PROCESSOR] Resizing to: $newWidth x $newHeight');
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        print(
          'ℹ️ [IMAGE PROCESSOR] Image already within size limits, no resize needed',
        );
        resizedImage = originalImage;
      }

      // Encode image
      Uint8List? encodedImage;
      final fileExtension = imageFile.path.split('.').last.toLowerCase();

      if (fileExtension == 'png') {
        encodedImage = Uint8List.fromList(img.encodePng(resizedImage));
        print(
          '✅ [IMAGE PROCESSOR] Encoded as PNG: ${encodedImage.length} bytes',
        );
      } else {
        encodedImage = Uint8List.fromList(
          img.encodeJpg(resizedImage, quality: quality),
        );
        print(
          '✅ [IMAGE PROCESSOR] Encoded as JPEG (quality: $quality): ${encodedImage.length} bytes',
        );
      }

      print('✅ [IMAGE PROCESSOR] Image processing completed');
      return encodedImage;
    } catch (e, stackTrace) {
      print('❌ [IMAGE PROCESSOR] Error processing image: $e');
      print('📚 [IMAGE PROCESSOR] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get content type from file extension
  static String getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get file type for API based on backend switch cases
  /// Valid file types:
  /// - user_profile_pic, mhp_profile_pic (for profile pictures)
  /// - company_logo, video_thumbnail, additional_images, ml_file, ml_jd
  /// - invoice, blog_media, masked_cv, smarthire_audio_file, cv_analysis
  /// - degree, custom_jd, pool_jd, applicant_invoice, post_image
  static String getFileType({
    required bool isProfilePicture,
    String? role, // 'user' or 'mhp' for profile pictures
    String? customFileType, // For non-profile pictures
  }) {
    if (isProfilePicture) {
      // Determine profile picture type based on role
      if (role != null) {
        final normalizedRole = role.toLowerCase();
        if (normalizedRole == 'mhp') {
          return 'mhp_profile_pic';
        } else if (normalizedRole == 'user') {
          return 'user_profile_pic';
        }
      }
      // Default to user_profile_pic if role not specified
      return 'user_profile_pic';
    }

    // For non-profile pictures, use custom file type
    if (customFileType != null) {
      // Validate that it's one of the allowed types
      final validTypes = [
        'company_logo',
        'video_thumbnail',
        'additional_images',
        'ml_file',
        'ml_jd',
        'invoice',
        'blog_media',
        'masked_cv',
        'smarthire_audio_file',
        'cv_analysis',
        'degree',
        'custom_jd',
        'pool_jd',
        'applicant_invoice',
        'post_image', // For social media post images
        'post_video', // For social media post videos
      ];

      if (validTypes.contains(customFileType)) {
        return customFileType;
      } else {
        throw ArgumentError(
          'Invalid file type: $customFileType. Valid types: ${validTypes.join(", ")}',
        );
      }
    }

    throw ArgumentError(
      'File type must be specified for non-profile pictures. '
      'Available types: company_logo, video_thumbnail, additional_images, ml_file, '
      'ml_jd, invoice, blog_media, masked_cv, smarthire_audio_file, cv_analysis, '
      'degree, custom_jd, pool_jd, applicant_invoice, post_image, post_video',
    );
  }
}
