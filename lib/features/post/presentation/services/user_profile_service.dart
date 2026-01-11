// presentation/services/user_profile_service.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../core/storage/token_storage.dart';

/// Service to fetch user profiles for post authors
class UserProfileService {
  final Dio _client;
  final Map<String, _CachedProfile> _cache = {};
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  UserProfileService({Dio? dio}) : _client = dio ?? ApiClient.dio;

  /// Fetches user profile by user ID
  Future<Map<String, String?>> getUserProfile(String userId) async {
    // Check cache first
    if (_cache.containsKey(userId)) {
      final cached = _cache[userId]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheValidDuration) {
        print('📦 [USER PROFILE SERVICE] Using cached profile for $userId');
        return cached.profile;
      } else {
        _cache.remove(userId);
      }
    }

    try {
      print('🔍 [USER PROFILE SERVICE] Fetching profile for user: $userId');
      final response = await _client.get(
        '/users/external/v1/profile/$userId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        Map<String, dynamic> profileData;
        
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          profileData = responseData['data'] as Map<String, dynamic>;
        } else {
          profileData = responseData;
        }

        // Extract username and picture_path
        var username = profileData['username'] as String?;
        if (username != null) {
          username = username.trim();
        }
        
        // If username is empty or null, try to get it from JWT token as fallback (only for current user)
        if (username == null || username.isEmpty) {
          print('🔍 [USER PROFILE SERVICE] Username is empty, attempting JWT fallback for userId: $userId');
          try {
            final token = await TokenStorage.getToken();
            if (token != null && token.isNotEmpty) {
              final jwtUserId = JwtDecoder.getUserId(token);
              print('🔍 [USER PROFILE SERVICE] JWT userId: $jwtUserId, requested userId: $userId');
              // Only use JWT username if the user ID matches (same user)
              if (jwtUserId == userId) {
                final jwtUsername = JwtDecoder.getUserName(token);
                print('🔍 [USER PROFILE SERVICE] JWT username: $jwtUsername');
                if (jwtUsername != null && jwtUsername.isNotEmpty) {
                  username = jwtUsername;
                  print('✅ [USER PROFILE SERVICE] Using JWT username fallback for current user: $username');
                } else {
                  print('⚠️ [USER PROFILE SERVICE] JWT username is null or empty');
                }
              } else {
                print('⚠️ [USER PROFILE SERVICE] JWT userId ($jwtUserId) does not match requested userId ($userId)');
              }
            } else {
              print('⚠️ [USER PROFILE SERVICE] Token is null or empty');
            }
          } catch (e, stackTrace) {
            print('❌ [USER PROFILE SERVICE] Error getting username from JWT: $e');
            print('❌ [USER PROFILE SERVICE] Stack trace: $stackTrace');
          }
        }
        
        final picturePath = profileData['picture_path'];
        
        // Return raw picture_path (not converted URL) - PostConverter will handle conversion via ProfilePictureHelper
        String? picturePathStr;
        if (picturePath != null) {
          final pathStr = picturePath.toString().trim();
          if (pathStr.isNotEmpty) {
            picturePathStr = pathStr;
          }
        }

        final profile = {
          'username': (username != null && username.isNotEmpty) ? username : null,
          'picture_path': picturePathStr,
        };
        
        print('📝 [USER PROFILE SERVICE] Profile data: username=${profile['username']}, picture_path=${profile['picture_path']}');

        // Cache the result
        _cache[userId] = _CachedProfile(
          profile: profile,
          timestamp: DateTime.now(),
        );

        print('✅ [USER PROFILE SERVICE] Fetched profile for $userId: username=${profile['username']}, picture_path=${profile['picture_path']}');
        return profile;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [USER PROFILE SERVICE] Error fetching profile for $userId: ${e.message}');
      if (e.response?.statusCode == 404) {
        // User profile not found - return null values
        return {'username': null, 'picture_path': null};
      }
      // For other errors, return null values (will use placeholders)
      return {'username': null, 'picture_path': null};
    } catch (e) {
      print('❌ [USER PROFILE SERVICE] Unexpected error: $e');
      return {'username': null, 'picture_path': null};
    }
  }

  /// Fetches profiles for multiple user IDs in parallel
  Future<Map<String, Map<String, String?>>> getUserProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    print('🔍 [USER PROFILE SERVICE] Fetching profiles for ${userIds.length} users');
    
    // Remove duplicates
    final uniqueUserIds = userIds.toSet().toList();
    
    // Fetch all profiles in parallel
    final futures = uniqueUserIds.map((userId) async {
      final profile = await getUserProfile(userId);
      return MapEntry(userId, profile);
    });

    final results = await Future.wait(futures);
    final profileMap = Map<String, Map<String, String?>>.fromEntries(results);

    print('✅ [USER PROFILE SERVICE] Fetched ${profileMap.length} profiles');
    return profileMap;
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

class _CachedProfile {
  final Map<String, String?> profile;
  final DateTime timestamp;

  _CachedProfile({required this.profile, required this.timestamp});
}

