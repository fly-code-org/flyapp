// presentation/controllers/user_profile_controller.dart
import 'package:get/get.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../core/utils/profile_picture_helper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/services/streak_engagement_service.dart';
import '../../../profile_creation/domain/usecases/get_user_profile.dart';
import '../../data/utils/default_profile_picture.dart';
import '../../data/services/profile_update_service.dart';
import '../../../streak/data/streak_patch_result.dart';
import '../../../streak/presentation/streak_view_model.dart';

class UserProfileController extends GetxController {
  final GetUserProfile getUserProfile;

  UserProfileController({GetUserProfile? getUserProfile})
      : getUserProfile = getUserProfile ?? sl<GetUserProfile>();

  // Profile data
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var profileData = Rxn<Map<String, dynamic>>();

  // Cached profile fields for easy access
  var username = ''.obs;
  var bio = ''.obs;
  var picturePath = ''.obs;
  var location = ''.obs;
  var createdAt = ''.obs;
  var streakCount = 0.obs;
  var streakLastEngagedAt = Rxn<DateTime>();
  var activities = <String>[].obs;
  var bookmarkedPosts = <Map<String, dynamic>>[].obs;

  // Cache timestamp to avoid unnecessary refetches
  DateTime? _lastFetchTime;
  static const Duration cacheValidDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    // Load cached data if available
    _loadCachedData();
  }

  void _loadCachedData() {
    // If we have cached data and it's still valid, use it
    if (profileData.value != null && _lastFetchTime != null) {
      final timeSinceFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceFetch < cacheValidDuration) {
        _updateObservableFields(profileData.value!);
        return;
      }
    }
  }

  Future<void> fetchUserProfile({bool forceRefresh = false}) async {
    // Skip if already loading
    if (isLoading.value) return;

    // Skip if cache is valid and not forcing refresh
    if (!forceRefresh &&
        profileData.value != null &&
        _lastFetchTime != null) {
      final timeSinceFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceFetch < cacheValidDuration) {
        print('📦 [PROFILE] Using cached profile data');
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [PROFILE] Fetching user profile...');
      final userProfile = await getUserProfile.call();

      print('✅ [PROFILE] Profile fetched successfully');
      print('📦 [PROFILE] Profile data keys: ${userProfile.keys.toList()}');
      print('📦 [PROFILE] Profile data: $userProfile');
      
      // Log specific fields for debugging
      print('📋 [PROFILE] Username from API: "${userProfile['username']}"');
      print('📋 [PROFILE] Bio from API: "${userProfile['bio']}"');
      print('📋 [PROFILE] Picture path from API: "${userProfile['picture_path']}"');

      profileData.value = userProfile;
      _lastFetchTime = DateTime.now();
      await _updateObservableFields(userProfile);

      print('✅ [PROFILE] Profile data updated in controller');
    } on ServerException catch (e) {
      print('❌ [PROFILE] ServerException: ${e.message}');
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      print('❌ [PROFILE] NetworkException: ${e.message}');
      errorMessage.value = e.message;
    } catch (e) {
      print('❌ [PROFILE] Unexpected error: $e');
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateObservableFields(Map<String, dynamic> data) async {
    print('🔍 [PROFILE] Updating observable fields from data: ${data.keys.toList()}');
    
    // Username - handle both string and null
    // If username is empty, try to get it from JWT token as fallback
    final usernameValue = data['username'];
    String finalUsername = '';
    if (usernameValue != null && usernameValue.toString().trim().isNotEmpty) {
      finalUsername = usernameValue.toString().trim();
    } else {
      // Fallback: try to get username from JWT token
      try {
        final token = await TokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          final jwtUsername = JwtDecoder.getUserName(token);
          if (jwtUsername != null && jwtUsername.isNotEmpty) {
            finalUsername = jwtUsername;
            print('📝 [PROFILE] Using username from JWT token: "$finalUsername"');
          }
        }
      } catch (e) {
        print('⚠️ [PROFILE] Could not get username from JWT: $e');
      }
    }
    username.value = finalUsername;
    print('📝 [PROFILE] Username set to: "${username.value}"');

    // Bio - handle null pointer from backend
    final bioValue = data['bio'];
    if (bioValue != null) {
      bio.value = bioValue.toString().trim();
    } else {
      bio.value = '';
    }
    print('📝 [PROFILE] Bio set to: "${bio.value}"');

    // Picture path - handle null pointer from backend, prepend CDN if relative
    final picPathValue = data['picture_path'];
    String picPath = '';
    if (picPathValue != null) {
      picPath = picPathValue.toString().trim();
    }
    
    if (picPath.isNotEmpty) {
      // Use ProfilePictureHelper to handle asset paths vs CDN URLs
      picturePath.value = ProfilePictureHelper.getProfilePictureUrl(picPath);
    } else {
      // If no profile picture, use random default picture
      try {
        final userId = data['user_id'] as String?;
        if (userId != null && userId.isNotEmpty) {
          // Use random default profile picture
          final randomProfilePicture = DefaultProfilePicture.getRandomProfilePicture(userId);
          picturePath.value = randomProfilePicture;
          print('🎲 [PROFILE] Assigned random default profile picture: ${picturePath.value}');
          
          // Try to save to backend (will fail gracefully if endpoint not available)
          _saveProfilePictureToBackend(userId, randomProfilePicture).catchError((e) {
            // Silently fail - saving is optional, just for future use
            print('⚠️ [PROFILE] Could not save profile picture to backend: $e');
          });
        } else {
          picturePath.value = '';
        }
      } catch (e) {
        print('⚠️ [PROFILE] Error assigning random profile picture: $e');
        picturePath.value = '';
      }
    }
    print('📝 [PROFILE] Picture path set to: "${picturePath.value}"');

    // Location - prefer location_details over geo_location
    String locationStr = '';
    if (data.containsKey('location_details') &&
        data['location_details'] != null) {
      final locationDetails = data['location_details'] as Map<String, dynamic>?;
      if (locationDetails != null) {
        final city = locationDetails['city'] as String? ?? '';
        final country = locationDetails['country'] as String? ?? '';
        if (city.isNotEmpty && country.isNotEmpty) {
          locationStr = '$city, $country';
        } else if (city.isNotEmpty) {
          locationStr = city;
        } else if (country.isNotEmpty) {
          locationStr = country;
        }
      }
    } else if (data.containsKey('geo_location') &&
        data['geo_location'] != null) {
      final geoLocation = data['geo_location'] as Map<String, dynamic>?;
      if (geoLocation != null) {
        final city = geoLocation['city'] as String? ?? '';
        final country = geoLocation['country'] as String? ?? '';
        if (city.isNotEmpty && country.isNotEmpty) {
          locationStr = '$city, $country';
        } else if (city.isNotEmpty) {
          locationStr = city;
        } else if (country.isNotEmpty) {
          locationStr = country;
        }
      }
    }
    location.value = locationStr;

    // Created date - format as "March 2025"
    if (data.containsKey('created_at') && data['created_at'] != null) {
      try {
        final createdAtStr = data['created_at'] as String;
        final dateTime = DateTime.parse(createdAtStr);
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        createdAt.value =
            '${months[dateTime.month - 1]} ${dateTime.year}';
      } catch (e) {
        print('⚠️ [PROFILE] Error parsing created_at: $e');
        createdAt.value = '';
      }
    } else {
      createdAt.value = '';
    }

    // Streak count + last engaged (for week UI)
    if (data.containsKey('streaks') && data['streaks'] != null) {
      final streaks = data['streaks'] as Map<String, dynamic>?;
      if (streaks != null) {
        streakCount.value = StreakViewModel.readScoreFromMap(streaks);
        final raw = streaks['last_engaged_at'];
        if (raw is String && raw.isNotEmpty) {
          streakLastEngagedAt.value = DateTime.tryParse(raw);
        } else {
          streakLastEngagedAt.value = null;
        }
        if (Get.isRegistered<StreakViewModel>()) {
          Get.find<StreakViewModel>().applyFromProfileMap(streaks);
        }
      }
    } else {
      streakCount.value = 0;
      streakLastEngagedAt.value = null;
      if (Get.isRegistered<StreakViewModel>()) {
        Get.find<StreakViewModel>().applyFromProfileMap(null);
      }
    }

    // Activities - extract post_ids
    activities.clear();
    if (data.containsKey('activity') && data['activity'] is List) {
      final activityList = data['activity'] as List;
      for (var activity in activityList) {
        if (activity is Map<String, dynamic> &&
            activity.containsKey('post_id')) {
          final postId = activity['post_id'] as String? ?? '';
          if (postId.isNotEmpty) {
            activities.add(postId);
          }
        }
      }
    }

    // Bookmarked posts
    bookmarkedPosts.clear();
    if (data.containsKey('bookmarked_posts') &&
        data['bookmarked_posts'] is List) {
      final bookmarkedList = data['bookmarked_posts'] as List;
      for (var bookmark in bookmarkedList) {
        if (bookmark is Map<String, dynamic>) {
          bookmarkedPosts.add(Map<String, dynamic>.from(bookmark));
        }
      }
    }

    print('✅ [PROFILE] Observable fields updated');
    print('   - Username: ${username.value}');
    print('   - Bio: ${bio.value}');
    print('   - Picture: ${picturePath.value}');
    print('   - Location: ${location.value}');
    print('   - Created: ${createdAt.value}');
    print('   - Streaks: ${streakCount.value}');
    print('   - Activities: ${activities.length}');
    print('   - Bookmarks: ${bookmarkedPosts.length}');
  }

  Future<void> updateStreak() async {
    await StreakEngagementService.instance.recordEngagement(reason: 'manual');
  }

  void applyStreakPatch(StreakPatchResult r) {
    streakCount.value = r.streaks.score;
    streakLastEngagedAt.value = r.streaks.lastEngagedAt;
    if (profileData.value != null) {
      final m = Map<String, dynamic>.from(profileData.value!);
      m['streaks'] = {
        'score': r.streaks.score,
        if (r.streaks.lastEngagedAt != null)
          'last_engaged_at': r.streaks.lastEngagedAt!.toUtc().toIso8601String(),
        'free_streak_uses': r.streaks.freeStreakUses,
        'paid_streak_credits': r.streaks.paidStreakCredits,
      };
      profileData.value = m;
    }
    if (Get.isRegistered<StreakViewModel>()) {
      Get.find<StreakViewModel>().applyFromProfileMap({
        'score': r.streaks.score,
        if (r.streaks.lastEngagedAt != null)
          'last_engaged_at': r.streaks.lastEngagedAt!.toUtc().toIso8601String(),
        'free_streak_uses': r.streaks.freeStreakUses,
        'paid_streak_credits': r.streaks.paidStreakCredits,
      });
    }
  }


  // Save profile picture to backend (placeholder for when endpoint is available)
  Future<void> _saveProfilePictureToBackend(String userId, String profilePictureUrl) async {
    try {
      // Extract the relative path from the full URL
      String relativePath = profilePictureUrl;
      if (profilePictureUrl.startsWith('https://cdn.flyapp.in')) {
        relativePath = profilePictureUrl.replaceFirst('https://cdn.flyapp.in', '');
      }
      
      final updateService = ProfileUpdateService();
      final success = await updateService.updateProfilePicture(relativePath);
      if (success) {
        print('✅ [PROFILE] Profile picture saved to backend: $relativePath');
      } else {
        print('ℹ️ [PROFILE] Profile picture update endpoint not yet available');
      }
    } catch (e) {
      // Silently fail - this is optional functionality
      print('⚠️ [PROFILE] Error saving profile picture to backend: $e');
    }
  }

  // Clear cache (useful for logout)
  void clearCache() {
    profileData.value = null;
    _lastFetchTime = null;
    username.value = '';
    bio.value = '';
    picturePath.value = '';
    location.value = '';
    createdAt.value = '';
    streakCount.value = 0;
    streakLastEngagedAt.value = null;
    activities.clear();
    bookmarkedPosts.clear();
    errorMessage.value = '';
  }
}

