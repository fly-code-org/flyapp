// core/services/s3_upload_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../utils/image_processor.dart';
import '../../features/file_upload/domain/usecases/get_presigned_url.dart';

class S3UploadService {
  final GetPresignedUrl getPresignedUrl;
  final Dio dio;

  S3UploadService({required this.getPresignedUrl, Dio? dio})
    : dio = dio ?? Dio();

  /// Upload file to S3 using presigned URL
  /// Returns the file path from S3 response
  ///
  /// For profile pictures: set isProfilePicture=true and provide role ('user' or 'mhp')
  /// For other files: set isProfilePicture=false and provide customFileType
  /// Valid customFileType values: company_logo, video_thumbnail, additional_images,
  /// ml_file, ml_jd, invoice, blog_media, masked_cv, smarthire_audio_file,
  /// cv_analysis, degree, custom_jd, pool_jd, applicant_invoice
  Future<String> uploadFile({
    required File file,
    required bool isProfilePicture,
    String? role, // 'user' or 'mhp' for profile pictures
    String? customFileType, // For non-profile pictures
    Function(double)? onProgress,
  }) async {
    try {
      print('🚀 [S3 UPLOAD] Starting file upload...');
      print('   - File path: ${file.path}');
      print('   - Is profile picture: $isProfilePicture');

      // Validate file exists
      if (!await file.exists()) {
        throw ServerException('File does not exist: ${file.path}');
      }
      print('✅ [S3 UPLOAD] File exists and is readable');

      // Get file name
      final fileName = file.path.split('/').last;
      print('   - File name: $fileName');

      // Process image if it's a profile picture (resize to 500x500)
      Uint8List? fileBytes;
      String contentType;
      String finalFileName = fileName;

      if (isProfilePicture) {
        print(
          '🖼️ [S3 UPLOAD] Processing profile picture (resizing to 500x500)...',
        );
        final processedBytes = await ImageProcessor.resizeImage(
          imageFile: file,
          maxWidth: 500,
          maxHeight: 500,
          quality: 85,
        );

        if (processedBytes != null) {
          fileBytes = processedBytes;
          // Update file extension if needed (convert to jpg for smaller size)
          final extension = file.path.split('.').last.toLowerCase();
          if (extension == 'png') {
            finalFileName = fileName.replaceAll('.png', '.jpg');
          }
          contentType = 'image/jpeg';
          print('✅ [S3 UPLOAD] Image processed: ${fileBytes.length} bytes');
        } else {
          print('⚠️ [S3 UPLOAD] Image processing failed, using original file');
          fileBytes = await file.readAsBytes();
          contentType = ImageProcessor.getContentType(file.path);
        }
      } else {
        // For degree certificates, use original file
        print('📄 [S3 UPLOAD] Using original file for degree certificate');
        fileBytes = await file.readAsBytes();
        contentType = ImageProcessor.getContentType(file.path);
      }

      print('   - Content type: $contentType');
      print('   - File size: ${fileBytes.length} bytes');

      // Get presigned URL
      print('🔍 [S3 UPLOAD] Requesting presigned URL...');
      String fileType;
      if (isProfilePicture) {
        fileType = ImageProcessor.getFileType(
          isProfilePicture: true,
          role: role,
        );
      } else {
        if (customFileType == null) {
          throw ArgumentError(
            'customFileType must be provided for non-profile pictures. '
            'Valid types: company_logo, video_thumbnail, additional_images, ml_file, '
            'ml_jd, invoice, blog_media, masked_cv, smarthire_audio_file, cv_analysis, '
            'degree, custom_jd, pool_jd, applicant_invoice',
          );
        }
        // Validate file type using ImageProcessor
        fileType = ImageProcessor.getFileType(
          isProfilePicture: false,
          customFileType: customFileType,
        );
      }

      print('   - File type: $fileType');

      final presignedUrlResponse = await getPresignedUrl(
        fileType: fileType,
        fileName: finalFileName,
        contentType: contentType,
      );

      print('✅ [S3 UPLOAD] Presigned URL received:');
      print('   - URL: ${presignedUrlResponse.url.substring(0, 100)}...');
      print('   - Path: ${presignedUrlResponse.path}');

      // Upload to S3 using presigned URL
      print('📤 [S3 UPLOAD] Uploading file to S3...');
      print(
        '   - Presigned URL: ${presignedUrlResponse.url.substring(0, 150)}...',
      );
      print('   - Content-Type: $contentType');
      print('   - File size: ${fileBytes.length} bytes');

      try {
        final uploadResponse = await dio.put(
          presignedUrlResponse.url,
          data: fileBytes,
          options: Options(
            headers: {'Content-Type': contentType},
            validateStatus: (status) =>
                true, // Accept all status codes to inspect response
            followRedirects: false,
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              final progress = sent / total;
              print(
                '📊 [S3 UPLOAD] Upload progress: ${(progress * 100).toStringAsFixed(1)}% ($sent/$total bytes)',
              );
              onProgress(progress);
            }
          },
        );

        print('📦 [S3 UPLOAD] Upload response received:');
        print('   - Status Code: ${uploadResponse.statusCode}');
        print('   - Status Message: ${uploadResponse.statusMessage}');
        print('   - Response Headers: ${uploadResponse.headers}');
        if (uploadResponse.data != null) {
          print('   - Response Data: ${uploadResponse.data}');
        }

        if (uploadResponse.statusCode == 200 ||
            uploadResponse.statusCode == 204) {
          print('✅ [S3 UPLOAD] File uploaded successfully');
          print('   - S3 Path: ${presignedUrlResponse.path}');
          return presignedUrlResponse.path;
        } else {
          final errorMessage =
              uploadResponse.data?.toString() ??
              'Unknown error (Status: ${uploadResponse.statusCode})';
          print('❌ [S3 UPLOAD] Upload failed:');
          print('   - Status Code: ${uploadResponse.statusCode}');
          print('   - Error: $errorMessage');
          throw ServerException(
            'Failed to upload file to S3. Status: ${uploadResponse.statusCode}, Error: $errorMessage',
          );
        }
      } on DioException catch (e) {
        print('❌ [S3 UPLOAD] DioException during upload:');
        print('   - Type: ${e.type}');
        print('   - Message: ${e.message}');
        print('   - Response: ${e.response?.data}');
        print('   - Status Code: ${e.response?.statusCode}');
        if (e.response != null) {
          throw ServerException(
            'S3 upload failed: ${e.response?.statusCode} - ${e.response?.data?.toString() ?? e.message}',
          );
        } else {
          throw NetworkException(
            'Network error during S3 upload: ${e.message}',
          );
        }
      }
    } on ServerException catch (e) {
      print('❌ [S3 UPLOAD] ServerException: ${e.message}');
      rethrow;
    } on NetworkException catch (e) {
      print('❌ [S3 UPLOAD] NetworkException: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ [S3 UPLOAD] Unexpected error: $e');
      print('📚 [S3 UPLOAD] Stack trace: $stackTrace');
      throw ServerException('Failed to upload file: ${e.toString()}');
    }
  }
}
