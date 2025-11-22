import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/storage/mhp_profile_cache.dart';
import '../../../core/services/s3_upload_service.dart';
import '../domain/usecases/create_mhp_profile.dart';
import '../domain/usecases/create_user_profile.dart';

class UserProfileController extends GetxController {
  var username = ''.obs;
  var selectedImage = Rxn<File>();

  // MHP Profile form fields
  var bio = ''.obs;
  var university = ''.obs;
  var degree = ''.obs;
  var yearsOfExperience = ''.obs;
  var languages = <String>[].obs;
  var workLocation = ''.obs;
  var certifiedMhp = false.obs;
  var degreePath = ''.obs;
  var communityId = ''.obs;
  var picturePath = ''.obs;
  var selectedDegreeFile = Rxn<PlatformFile>(); // Store selected file info

  // User Profile form fields
  var firstName = ''.obs;
  var lastName = ''.obs;
  var dateOfBirth = ''.obs;
  var mood = ''.obs;
  var followedInterests = <Map<String, String>>[].obs;
  var activity = <Map<String, String>>[].obs;
  var bookmarkedPosts = <Map<String, dynamic>>[].obs;

  // API related
  final CreateMhpProfile? createMhpProfile;
  final CreateUserProfile? createUserProfile;
  final S3UploadService? s3UploadService;
  var role = 'user'.obs; // Current role: 'user' or 'mhp'
  var isLoading = false.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;
  var uploadProgress = 0.0.obs; // Upload progress (0.0 to 1.0)
  var isUploading = false.obs; // Whether file is currently uploading

  UserProfileController({
    this.createMhpProfile,
    this.createUserProfile,
    this.s3UploadService,
  });

  /// Pick a PDF or document file
  Future<void> pickDegreeFile() async {
    print('🔍 [PICK DEGREE FILE] Starting file picker...');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('✅ [PICK DEGREE FILE] File selected: ${file.name}');
        print('   - Path: ${file.path}');
        print('   - Size: ${file.size} bytes');
        print('   - Extension: ${file.extension}');

        selectedDegreeFile.value = file;

        // Don't set degreePath here - it will be set after S3 upload
        // Clear any previous S3 path so upload will trigger
        degreePath.value = '';
        print(
          '✅ [PICK DEGREE FILE] File selected, will upload to S3 on profile creation',
        );

        update(); // Notify listeners
      } else {
        print('ℹ️ [PICK DEGREE FILE] User cancelled file picker');
      }
    } catch (e, stackTrace) {
      print('❌ [PICK DEGREE FILE] Error picking file: $e');
      print('📚 [PICK DEGREE FILE] Stack trace: $stackTrace');
      errorMessage.value = 'Error picking file: $e';
      update();
    }
  }

  /// Save profile data to cache
  Future<void> saveToCache() async {
    print('💾 [SAVE TO CACHE] Starting to save profile data...');
    try {
      print('🔍 [SAVE TO CACHE] Accessing picturePath...');
      final picPath = picturePath.value;
      print('✅ [SAVE TO CACHE] picturePath.value = "$picPath"');

      print('🔍 [SAVE TO CACHE] Accessing bio...');
      final bioValue = bio.value;
      print('✅ [SAVE TO CACHE] bio.value = "$bioValue"');

      print('🔍 [SAVE TO CACHE] Accessing university...');
      final uniValue = university.value;
      print('✅ [SAVE TO CACHE] university.value = "$uniValue"');

      print('🔍 [SAVE TO CACHE] Accessing degree...');
      final degreeValue = degree.value;
      print('✅ [SAVE TO CACHE] degree.value = "$degreeValue"');

      print('🔍 [SAVE TO CACHE] Accessing workLocation...');
      final workLocValue = workLocation.value;
      print('✅ [SAVE TO CACHE] workLocation.value = "$workLocValue"');

      print('🔍 [SAVE TO CACHE] Accessing certifiedMhp...');
      final certValue = certifiedMhp.value;
      print('✅ [SAVE TO CACHE] certifiedMhp.value = $certValue');

      print('🔍 [SAVE TO CACHE] Accessing degreePath...');
      final degPathValue = degreePath.value;
      print('✅ [SAVE TO CACHE] degreePath.value = "$degPathValue"');

      print('🔍 [SAVE TO CACHE] Accessing yearsOfExperience...');
      final yearsValue = yearsOfExperience.value;
      print('✅ [SAVE TO CACHE] yearsOfExperience.value = "$yearsValue"');

      print('🔍 [SAVE TO CACHE] Accessing languages...');
      final langsList = languages.toList();
      print('✅ [SAVE TO CACHE] languages.toList() = $langsList');

      print('🔍 [SAVE TO CACHE] Accessing communityId...');
      final commIdValue = communityId.value;
      print('✅ [SAVE TO CACHE] communityId.value = "$commIdValue"');

      final profileData = <String, dynamic>{
        if (picPath.isNotEmpty) 'picture_path': picPath,
        if (bioValue.isNotEmpty) 'bio': bioValue,
        if (uniValue.isNotEmpty) 'university': uniValue,
        if (degreeValue.isNotEmpty) 'degree': degreeValue,
        if (workLocValue.isNotEmpty) 'work_location': workLocValue,
        'certified_mhp': certValue,
        if (degPathValue.isNotEmpty) 'degree_path': degPathValue,
        if (yearsValue.isNotEmpty)
          'years_of_experience': int.tryParse(yearsValue) ?? 0,
        if (langsList.isNotEmpty) 'languages': langsList,
        if (commIdValue.isNotEmpty) 'community_id': commIdValue,
      };

      print('💾 [SAVE TO CACHE] Profile data map created: $profileData');
      print('🔍 [SAVE TO CACHE] Saving to MhpProfileCache...');
      await MhpProfileCache.saveProfileData(profileData);
      print('✅ [SAVE TO CACHE] Profile data saved to cache successfully');
    } catch (e, stackTrace) {
      print('❌ [SAVE TO CACHE] Error saving to cache: $e');
      print('📚 [SAVE TO CACHE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Upload profile picture to S3
  /// role: 'user' or 'mhp' to determine file type (user_profile_pic or mhp_profile_pic)
  Future<String?> uploadProfilePicture(
    File imageFile, {
    String? roleOverride,
  }) async {
    if (s3UploadService == null) {
      print('❌ [UPLOAD PROFILE PICTURE] S3UploadService is null!');
      errorMessage.value = 'File upload service not available';
      return null;
    }

    try {
      print('🚀 [UPLOAD PROFILE PICTURE] Starting upload...');
      isUploading.value = true;
      uploadProgress.value = 0.0;
      errorMessage.value = '';

      // Use roleOverride if provided, otherwise use controller's role
      final uploadRole = roleOverride ?? role.value;
      print('   - Role: $uploadRole');

      final s3Path = await s3UploadService!.uploadFile(
        file: imageFile,
        isProfilePicture: true,
        role: uploadRole,
        onProgress: (progress) {
          uploadProgress.value = progress;
          print(
            '📊 [UPLOAD PROFILE PICTURE] Progress: ${(progress * 100).toStringAsFixed(1)}%',
          );
        },
      );

      print('✅ [UPLOAD PROFILE PICTURE] Upload successful: $s3Path');
      picturePath.value = s3Path;
      isUploading.value = false;
      uploadProgress.value = 1.0;
      return s3Path;
    } catch (e) {
      print('❌ [UPLOAD PROFILE PICTURE] Error: $e');
      errorMessage.value = 'Failed to upload profile picture: ${e.toString()}';
      isUploading.value = false;
      uploadProgress.value = 0.0;
      return null;
    }
  }

  /// Upload degree certificate to S3
  /// customFileType: One of the valid backend file types
  /// Default: 'degree' (maps to "mhp/degree/" path in S3)
  Future<String?> uploadDegreeCertificate(
    File certificateFile, {
    String customFileType = 'degree',
  }) async {
    if (s3UploadService == null) {
      print('❌ [UPLOAD DEGREE CERTIFICATE] S3UploadService is null!');
      errorMessage.value = 'File upload service not available';
      return null;
    }

    try {
      print('🚀 [UPLOAD DEGREE CERTIFICATE] Starting upload...');
      isUploading.value = true;
      uploadProgress.value = 0.0;
      errorMessage.value = '';

      // File type 'degree' maps to "mhp/degree/" path in S3 bucket
      // Available types: company_logo, video_thumbnail, additional_images, ml_file,
      // ml_jd, invoice, blog_media, masked_cv, smarthire_audio_file, cv_analysis,
      // degree, custom_jd, pool_jd, applicant_invoice
      final s3Path = await s3UploadService!.uploadFile(
        file: certificateFile,
        isProfilePicture: false,
        customFileType: customFileType,
        onProgress: (progress) {
          uploadProgress.value = progress;
          print(
            '📊 [UPLOAD DEGREE CERTIFICATE] Progress: ${(progress * 100).toStringAsFixed(1)}%',
          );
        },
      );

      print('✅ [UPLOAD DEGREE CERTIFICATE] Upload successful: $s3Path');
      degreePath.value = s3Path;
      isUploading.value = false;
      uploadProgress.value = 1.0;
      return s3Path;
    } catch (e) {
      print('❌ [UPLOAD DEGREE CERTIFICATE] Error: $e');
      errorMessage.value =
          'Failed to upload degree certificate: ${e.toString()}';
      isUploading.value = false;
      uploadProgress.value = 0.0;
      return null;
    }
  }

  /// Create MHP profile via API
  Future<bool> createProfile() async {
    print('🚀 [CREATE PROFILE] Starting profile creation...');
    print(
      '🔍 [CREATE PROFILE] Checking createMhpProfile: ${createMhpProfile != null}',
    );
    if (createMhpProfile == null) {
      print('❌ [CREATE PROFILE] createMhpProfile is null!');
      try {
        errorMessage.value = 'Profile creation service not available';
        print('✅ [CREATE PROFILE] Error message set');
      } catch (e, stackTrace) {
        print('❌ [CREATE PROFILE] Error setting errorMessage: $e');
        print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      }
      return false;
    }

    try {
      print('🔍 [CREATE PROFILE] Setting isLoading to true...');
      isLoading.value = true;
      print('✅ [CREATE PROFILE] isLoading set to true');

      print('🔍 [CREATE PROFILE] Clearing errorMessage...');
      errorMessage.value = '';
      print('✅ [CREATE PROFILE] errorMessage cleared');

      print('🔍 [CREATE PROFILE] Clearing message...');
      message.value = '';
      print('✅ [CREATE PROFILE] message cleared');

      print('🔍 [CREATE PROFILE] Calling update()...');
      update(); // Notify GetBuilder listeners
      print('✅ [CREATE PROFILE] update() called');
    } catch (e, stackTrace) {
      print('❌ [CREATE PROFILE] Error setting initial state: $e');
      print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      rethrow;
    }

    try {
      // Upload profile picture if selected
      print('🔍 [CREATE PROFILE] Checking if profile picture needs upload...');
      print('   - selectedImage.value: ${selectedImage.value?.path ?? "null"}');
      print('   - picturePath.value: "${picturePath.value}"');
      print('   - picturePath.value.isEmpty: ${picturePath.value.isEmpty}');

      if (selectedImage.value != null) {
        // Check if already uploaded (has S3 path) or needs upload
        if (picturePath.value.isEmpty || !picturePath.value.startsWith('/')) {
          print('📸 [CREATE PROFILE] Profile picture needs upload to S3...');
          final uploadedPath = await uploadProfilePicture(selectedImage.value!);
          if (uploadedPath == null) {
            print('❌ [CREATE PROFILE] Profile picture upload failed');
            return false;
          }
          print('✅ [CREATE PROFILE] Profile picture uploaded: $uploadedPath');
        } else {
          print(
            'ℹ️ [CREATE PROFILE] Profile picture already uploaded: ${picturePath.value}',
          );
        }
      } else {
        print('ℹ️ [CREATE PROFILE] No profile picture selected');
      }

      // Upload degree certificate if selected
      print(
        '🔍 [CREATE PROFILE] Checking if degree certificate needs upload...',
      );
      print(
        '   - selectedDegreeFile.value: ${selectedDegreeFile.value?.path ?? "null"}',
      );
      print('   - degreePath.value: "${degreePath.value}"');
      print('   - degreePath.value.isEmpty: ${degreePath.value.isEmpty}');

      if (selectedDegreeFile.value != null &&
          selectedDegreeFile.value!.path != null) {
        // Check if already uploaded (has S3 path) or needs upload
        // S3 paths typically start with '/' and don't contain '/tmp/' or '/private/'
        final isLocalPath =
            degreePath.value.contains('/tmp/') ||
            degreePath.value.contains('/private/') ||
            degreePath.value.contains('Containers/Data/Application/');

        if (degreePath.value.isEmpty || isLocalPath) {
          print('📄 [CREATE PROFILE] Degree certificate needs upload to S3...');
          final certificateFile = File(selectedDegreeFile.value!.path!);
          final uploadedPath = await uploadDegreeCertificate(certificateFile);
          if (uploadedPath == null) {
            print('❌ [CREATE PROFILE] Degree certificate upload failed');
            return false;
          }
          print(
            '✅ [CREATE PROFILE] Degree certificate uploaded: $uploadedPath',
          );
        } else {
          print(
            'ℹ️ [CREATE PROFILE] Degree certificate already uploaded: ${degreePath.value}',
          );
        }
      } else {
        print('ℹ️ [CREATE PROFILE] No degree certificate selected');
      }

      print('🔍 [CREATE PROFILE] Getting cached data...');
      final cachedData = await MhpProfileCache.getProfileData();
      print('✅ [CREATE PROFILE] Cached data retrieved: $cachedData');

      print('🔍 [CREATE PROFILE] Accessing form fields to merge with cache...');

      print('   - Accessing picturePath...');
      final picPath = picturePath.value;
      print('   ✅ picturePath.value = "$picPath"');

      print('   - Accessing bio...');
      final bioValue = bio.value;
      print('   ✅ bio.value = "$bioValue"');

      print('   - Accessing university...');
      final uniValue = university.value;
      print('   ✅ university.value = "$uniValue"');

      print('   - Accessing degree...');
      final degreeValue = degree.value;
      print('   ✅ degree.value = "$degreeValue"');

      print('   - Accessing workLocation...');
      final workLocValue = workLocation.value;
      print('   ✅ workLocation.value = "$workLocValue"');

      print('   - Accessing certifiedMhp...');
      final certValue = certifiedMhp.value;
      print('   ✅ certifiedMhp.value = $certValue');

      print('   - Accessing degreePath...');
      final degPathValue = degreePath.value;
      print('   ✅ degreePath.value = "$degPathValue"');

      print('   - Accessing yearsOfExperience...');
      final yearsValue = yearsOfExperience.value;
      print('   ✅ yearsOfExperience.value = "$yearsValue"');

      print('   - Accessing languages...');
      final langsList = languages.toList();
      print('   ✅ languages.toList() = $langsList');

      print('   - Accessing communityId...');
      final commIdValue = communityId.value;
      print('   ✅ communityId.value = "$commIdValue"');

      // Merge with current form data
      final profileData = <String, dynamic>{
        ...cachedData,
        if (picPath.isNotEmpty) 'picture_path': picPath,
        if (bioValue.isNotEmpty) 'bio': bioValue,
        if (uniValue.isNotEmpty) 'university': uniValue,
        if (degreeValue.isNotEmpty) 'degree': degreeValue,
        if (workLocValue.isNotEmpty) 'work_location': workLocValue,
        'certified_mhp': certValue,
        if (degPathValue.isNotEmpty) 'degree_path': degPathValue,
        if (yearsValue.isNotEmpty)
          'years_of_experience': int.tryParse(yearsValue) ?? 0,
        if (langsList.isNotEmpty) 'languages': langsList,
        if (commIdValue.isNotEmpty) 'community_id': commIdValue,
      };

      print('✅ [CREATE PROFILE] Profile data map created: $profileData');
      print('🚀 [CREATE PROFILE] Calling createMhpProfile use case...');

      final response = await createMhpProfile!(profileData: profileData);

      print('✅ [CREATE PROFILE] Profile created successfully');
      print('📨 [CREATE PROFILE] Response message: ${response.message}');

      print('🔍 [CREATE PROFILE] Setting message.value...');
      message.value = response.message;
      print('✅ [CREATE PROFILE] message.value set');

      print('🔍 [CREATE PROFILE] Clearing cache...');
      await MhpProfileCache.clearCache();
      print('✅ [CREATE PROFILE] Cache cleared');

      print('🔍 [CREATE PROFILE] Calling update()...');
      update(); // Notify GetBuilder listeners
      print('✅ [CREATE PROFILE] update() called');

      print('✅ [CREATE PROFILE] Returning true');
      return true;
    } on ServerException catch (e) {
      print('❌ [CREATE PROFILE] ServerException: ${e.message}');
      try {
        errorMessage.value = e.message;
        update();
      } catch (updateError, stackTrace) {
        print(
          '❌ [CREATE PROFILE] Error updating on ServerException: $updateError',
        );
        print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      }
      return false;
    } on NetworkException catch (e) {
      print('❌ [CREATE PROFILE] NetworkException: ${e.message}');
      try {
        errorMessage.value = e.message;
        update();
      } catch (updateError, stackTrace) {
        print(
          '❌ [CREATE PROFILE] Error updating on NetworkException: $updateError',
        );
        print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      }
      return false;
    } catch (e, stackTrace) {
      print('❌ [CREATE PROFILE] Unexpected error: $e');
      print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      try {
        errorMessage.value = e.toString();
        update();
      } catch (updateError, updateStackTrace) {
        print(
          '❌ [CREATE PROFILE] Error updating on unexpected error: $updateError',
        );
        print('📚 [CREATE PROFILE] Update stack trace: $updateStackTrace');
      }
      return false;
    } finally {
      print(
        '🔍 [CREATE PROFILE] Finally block - setting isLoading to false...',
      );
      try {
        isLoading.value = false;
        print('✅ [CREATE PROFILE] isLoading set to false');
        update();
        print('✅ [CREATE PROFILE] update() called in finally');
      } catch (e, stackTrace) {
        print('❌ [CREATE PROFILE] Error in finally block: $e');
        print('📚 [CREATE PROFILE] Stack trace: $stackTrace');
      }
      print('🏁 [CREATE PROFILE] Profile creation process completed');
    }
  }

  /// Create User profile via API
  Future<bool> createUserProfileAPI() async {
    print('🚀 [CREATE USER PROFILE] Starting user profile creation...');
    print(
      '🔍 [CREATE USER PROFILE] Checking createUserProfile: ${createUserProfile != null}',
    );
    if (createUserProfile == null) {
      print('❌ [CREATE USER PROFILE] createUserProfile is null!');
      try {
        errorMessage.value = 'Profile creation service not available';
        print('✅ [CREATE USER PROFILE] Error message set');
      } catch (e, stackTrace) {
        print('❌ [CREATE USER PROFILE] Error setting errorMessage: $e');
        print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      }
      return false;
    }

    try {
      print('🔍 [CREATE USER PROFILE] Setting isLoading to true...');
      isLoading.value = true;
      print('✅ [CREATE USER PROFILE] isLoading set to true');

      print('🔍 [CREATE USER PROFILE] Clearing errorMessage...');
      errorMessage.value = '';
      print('✅ [CREATE USER PROFILE] errorMessage cleared');

      print('🔍 [CREATE USER PROFILE] Clearing message...');
      message.value = '';
      print('✅ [CREATE USER PROFILE] message cleared');

      print('🔍 [CREATE USER PROFILE] Calling update()...');
      update(); // Notify GetBuilder listeners
      print('✅ [CREATE USER PROFILE] update() called');
    } catch (e, stackTrace) {
      print('❌ [CREATE USER PROFILE] Error setting initial state: $e');
      print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      rethrow;
    }

    try {
      // Upload profile picture if selected
      print(
        '🔍 [CREATE USER PROFILE] Checking if profile picture needs upload...',
      );
      print('   - selectedImage.value: ${selectedImage.value?.path ?? "null"}');
      print('   - picturePath.value: "${picturePath.value}"');
      print('   - picturePath.value.isEmpty: ${picturePath.value.isEmpty}');

      if (selectedImage.value != null) {
        // Check if already uploaded (has S3 path) or needs upload
        if (picturePath.value.isEmpty || !picturePath.value.startsWith('/')) {
          print(
            '📸 [CREATE USER PROFILE] Profile picture needs upload to S3...',
          );
          final uploadedPath = await uploadProfilePicture(selectedImage.value!);
          if (uploadedPath == null) {
            print('❌ [CREATE USER PROFILE] Profile picture upload failed');
            return false;
          }
          print(
            '✅ [CREATE USER PROFILE] Profile picture uploaded: $uploadedPath',
          );
        } else {
          print(
            'ℹ️ [CREATE USER PROFILE] Profile picture already uploaded: ${picturePath.value}',
          );
        }
      } else {
        print('ℹ️ [CREATE USER PROFILE] No profile picture selected');
      }

      print('🔍 [CREATE USER PROFILE] Accessing form fields...');

      print('   - Accessing username...');
      final usernameValue = username.value;
      print('   ✅ username.value = "$usernameValue"');

      print('   - Accessing picturePath...');
      final picPath = picturePath.value;
      print('   ✅ picturePath.value = "$picPath"');

      print('   - Accessing bio...');
      final bioValue = bio.value;
      print('   ✅ bio.value = "$bioValue"');

      print('   - Accessing followedInterests...');
      final interestsList = followedInterests.toList();
      print('   ✅ followedInterests.toList() = $interestsList');

      print('   - Accessing activity...');
      final activityList = activity.toList();
      print('   ✅ activity.toList() = $activityList');

      print('   - Accessing bookmarkedPosts...');
      final bookmarkedList = bookmarkedPosts.toList();
      print('   ✅ bookmarkedPosts.toList() = $bookmarkedList');

      // Build profile data for user profile API
      final profileData = <String, dynamic>{
        'username': usernameValue,
        if (picPath.isNotEmpty) 'picture_path': picPath,
        if (bioValue.isNotEmpty) 'bio': bioValue,
        if (interestsList.isNotEmpty) 'followed_interests': interestsList,
        if (activityList.isNotEmpty) 'activity': activityList,
        if (bookmarkedList.isNotEmpty) 'bookmarked_posts': bookmarkedList,
      };

      print('✅ [CREATE USER PROFILE] Profile data map created: $profileData');
      print('🚀 [CREATE USER PROFILE] Calling createUserProfile use case...');

      final response = await createUserProfile!(profileData: profileData);

      print('✅ [CREATE USER PROFILE] Profile created successfully');
      print('📨 [CREATE USER PROFILE] Response message: ${response.message}');

      print('🔍 [CREATE USER PROFILE] Setting message.value...');
      message.value = response.message;
      print('✅ [CREATE USER PROFILE] message.value set');

      print('🔍 [CREATE USER PROFILE] Calling update()...');
      update(); // Notify GetBuilder listeners
      print('✅ [CREATE USER PROFILE] update() called');

      print('✅ [CREATE USER PROFILE] Returning true');
      return true;
    } on ServerException catch (e) {
      print('❌ [CREATE USER PROFILE] ServerException: ${e.message}');
      try {
        errorMessage.value = e.message;
        update();
      } catch (updateError, stackTrace) {
        print(
          '❌ [CREATE USER PROFILE] Error updating on ServerException: $updateError',
        );
        print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      }
      return false;
    } on NetworkException catch (e) {
      print('❌ [CREATE USER PROFILE] NetworkException: ${e.message}');
      try {
        errorMessage.value = e.message;
        update();
      } catch (updateError, stackTrace) {
        print(
          '❌ [CREATE USER PROFILE] Error updating on NetworkException: $updateError',
        );
        print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      }
      return false;
    } catch (e, stackTrace) {
      print('❌ [CREATE USER PROFILE] Unexpected error: $e');
      print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      try {
        errorMessage.value = e.toString();
        update();
      } catch (updateError, updateStackTrace) {
        print(
          '❌ [CREATE USER PROFILE] Error updating on unexpected error: $updateError',
        );
        print('📚 [CREATE USER PROFILE] Update stack trace: $updateStackTrace');
      }
      return false;
    } finally {
      print(
        '🔍 [CREATE USER PROFILE] Finally block - setting isLoading to false...',
      );
      try {
        isLoading.value = false;
        print('✅ [CREATE USER PROFILE] isLoading set to false');
        update();
        print('✅ [CREATE USER PROFILE] update() called in finally');
      } catch (e, stackTrace) {
        print('❌ [CREATE USER PROFILE] Error in finally block: $e');
        print('📚 [CREATE USER PROFILE] Stack trace: $stackTrace');
      }
      print('🏁 [CREATE USER PROFILE] Profile creation process completed');
    }
  }
}
