import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/storage/mhp_profile_cache.dart';
import '../domain/usecases/create_mhp_profile.dart';

class UserProfileController extends GetxController {
  var username = ''.obs;
  var selectedImage = Rxn<File>();

  // Profile form fields
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

  // API related
  final CreateMhpProfile? createMhpProfile;
  var isLoading = false.obs;
  var message = ''.obs;
  var errorMessage = ''.obs;

  UserProfileController({this.createMhpProfile});

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

        // Set degreePath to the file path
        if (file.path != null) {
          degreePath.value = file.path!;
          print('✅ [PICK DEGREE FILE] degreePath set to: ${degreePath.value}');
        } else {
          // For web or if path is null, use the file name
          degreePath.value = '/${file.name}';
          print(
            '✅ [PICK DEGREE FILE] degreePath set to file name: ${degreePath.value}',
          );
        }

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
}
