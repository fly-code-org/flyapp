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

  /// Bump when display-name resolution changes so stale cached nulls are not reused.
  static const int _cacheSchemaVersion = 2;

  /// API keys to try in order. `user_name` early — Mongo Users collection uses it.
  static const List<String> _profileDisplayNameKeys = [
    'username',
    'user_name',
    'display_name',
    'displayName',
    'name',
  ];

  UserProfileService({Dio? dio}) : _client = dio ?? ApiClient.dio;

  static String _profileCacheKey(String userId) =>
      '${userId}_dn$_cacheSchemaVersion';

  static String? _normalizeStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final t = value.trim();
      return t.isEmpty ? null : t;
    }
    final t = value.toString().trim();
    return t.isEmpty ? null : t;
  }

  /// Display name from one map: handle fields + optional first/last name (Mongo-style).
  static String? _displayNameFromFlatMap(Map<String, dynamic> m) {
    for (final key in _profileDisplayNameKeys) {
      final s = _normalizeStringField(m[key]);
      if (s != null) return s;
    }
    final fn = _normalizeStringField(m['first_name']);
    final ln = _normalizeStringField(m['last_name']);
    if (fn != null && ln != null) return '$fn $ln';
    if (fn != null) return fn;
    if (ln != null) return ln;
    return null;
  }

  /// Top-level and nested maps (`profile`, `user`, …) as returned by various API shapes.
  static String? _resolveDisplayNameFromProfile(Map<String, dynamic> profileData) {
    final direct = _displayNameFromFlatMap(profileData);
    if (direct != null) return direct;
    for (final nestedKey in <String>['profile', 'user', 'user_profile']) {
      final nested = profileData[nestedKey];
      if (nested is Map<String, dynamic>) {
        final n = _displayNameFromFlatMap(nested);
        if (n != null) return n;
      }
    }
    return null;
  }

  /// Fetches user profile by user ID
  Future<Map<String, String?>> getUserProfile(String userId) async {
    final cacheKey = _profileCacheKey(userId);
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheValidDuration) {
        print('📦 [USER PROFILE SERVICE] Using cached profile for $userId');
        return cached.profile;
      } else {
        _cache.remove(cacheKey);
      }
    }

    try {
      print('🔍 [USER PROFILE SERVICE] Fetching profile for user: $userId');
      print('🔍 [USER PROFILE SERVICE] API endpoint: /users/external/v1/profile/$userId');
      
      final response = await _client.get(
        '/users/external/v1/profile/$userId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      
      print('📦 [USER PROFILE SERVICE] API Response Status: ${response.statusCode}');
      print('📦 [USER PROFILE SERVICE] API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        Map<String, dynamic> profileData;
        
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          profileData = responseData['data'] as Map<String, dynamic>;
        } else {
          profileData = responseData;
        }

        // Verify that the user_id in the response matches the requested userId
        final responseUserId = profileData['user_id'];
        print('🔍 [USER PROFILE SERVICE] Response user_id: $responseUserId (type: ${responseUserId.runtimeType})');
        print('🔍 [USER PROFILE SERVICE] Requested userId: $userId');
        
        // Display name: prefer `username`, then other common API / Firestore-mapped keys
        var username = _resolveDisplayNameFromProfile(profileData);

        print('🔍 [USER PROFILE SERVICE] Extracted username for $userId: "$username" (type: ${username.runtimeType})');
        print('🔍 [USER PROFILE SERVICE] Full profileData keys: ${profileData.keys.toList()}');
        print('🔍 [USER PROFILE SERVICE] Full profileData: $profileData');
        
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

        final profile = <String, String?>{
          'username': (username != null && username.toString().isNotEmpty) ? username.toString() : null,
          'picture_path': picturePathStr,
        };
        
        print('📝 [USER PROFILE SERVICE] Profile data: username=${profile['username']}, picture_path=${profile['picture_path']}');

        // Cache the result
        _cache[cacheKey] = _CachedProfile(
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
              print('❌ [USER PROFILE SERVICE] Error fetching user profile for $userId: ${e.message}');
              if (e.response?.statusCode == 404) {
                // User profile not found - try MHP profile endpoint
                print('🔍 [USER PROFILE SERVICE] User profile not found, trying MHP profile for $userId');
                final mhpProfile = await _fetchMhpProfile(userId);
                if (mhpProfile != null) {
                  _cache[cacheKey] = _CachedProfile(
                    profile: mhpProfile,
                    timestamp: DateTime.now(),
                  );
                  return mhpProfile;
                }
                return {'username': null, 'picture_path': null};
              }
              // For other errors (like 500), try JWT fallback if it's the current user
              print('⚠️ [USER PROFILE SERVICE] API call failed, attempting JWT fallback for userId: $userId');
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
                      print('✅ [USER PROFILE SERVICE] Using JWT username fallback for current user: $jwtUsername');
                      return {'username': jwtUsername, 'picture_path': null};
                    } else {
                      print('⚠️ [USER PROFILE SERVICE] JWT username is null or empty');
                    }
                  } else {
                    print('⚠️ [USER PROFILE SERVICE] JWT userId ($jwtUserId) does not match requested userId ($userId)');
                  }
                } else {
                  print('⚠️ [USER PROFILE SERVICE] Token is null or empty');
                }
              } catch (jwtError) {
                print('❌ [USER PROFILE SERVICE] Error getting username from JWT: $jwtError');
              }
              // If JWT fallback also fails, return null values (will use placeholders)
              return {'username': null, 'picture_path': null};
            } catch (e) {
              print('❌ [USER PROFILE SERVICE] Unexpected error: $e');
              // Try JWT fallback on unexpected errors too
              try {
                final token = await TokenStorage.getToken();
                if (token != null && token.isNotEmpty) {
                  final jwtUserId = JwtDecoder.getUserId(token);
                  if (jwtUserId == userId) {
                    final jwtUsername = JwtDecoder.getUserName(token);
                    if (jwtUsername != null && jwtUsername.isNotEmpty) {
                      print('✅ [USER PROFILE SERVICE] Using JWT username fallback (unexpected error): $jwtUsername');
                      return {'username': jwtUsername, 'picture_path': null};
                    }
                  }
                }
              } catch (jwtError) {
                print('❌ [USER PROFILE SERVICE] Error getting username from JWT: $jwtError');
              }
              return {'username': null, 'picture_path': null};
            }
  }

  /// Fetches MHP profile by user ID (fallback when user profile not found)
  Future<Map<String, String?>?> _fetchMhpProfile(String userId) async {
    try {
      print('🔍 [USER PROFILE SERVICE] Fetching MHP profile for: $userId');

      final response = await _client.get(
        '/mhp/external/v1/profile/$userId',
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

        // MHP profile uses 'name' or 'display_name' for the display name
        String? displayName = _normalizeStringField(profileData['name']) ??
            _normalizeStringField(profileData['display_name']) ??
            _normalizeStringField(profileData['username']);

        // Also check nested 'user' or 'profile' objects
        if (displayName == null) {
          for (final nestedKey in <String>['profile', 'user']) {
            final nested = profileData[nestedKey];
            if (nested is Map<String, dynamic>) {
              displayName = _normalizeStringField(nested['name']) ??
                  _normalizeStringField(nested['display_name']) ??
                  _normalizeStringField(nested['username']);
              if (displayName != null) break;
            }
          }
        }

        final picturePath = profileData['picture_path'] ?? profileData['profile_picture'];
        String? picturePathStr;
        if (picturePath != null) {
          final pathStr = picturePath.toString().trim();
          if (pathStr.isNotEmpty) {
            picturePathStr = pathStr;
          }
        }

        print('✅ [USER PROFILE SERVICE] MHP profile found: name=$displayName, picture=$picturePathStr');
        return {
          'username': displayName,
          'picture_path': picturePathStr,
        };
      }
      return null;
    } catch (e) {
      print('❌ [USER PROFILE SERVICE] Error fetching MHP profile: $e');
      return null;
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

