// core/storage/mhp_profile_cache.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MhpProfileCache {
  static const String _cacheKey = 'mhp_profile_cache';

  /// Save MHP profile data to cache
  static Future<void> saveProfileData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = await getProfileData();
    final mergedData = {...existingData, ...data};
    await prefs.setString(_cacheKey, json.encode(mergedData));
  }

  /// Get MHP profile data from cache
  static Future<Map<String, dynamic>> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_cacheKey);
    if (dataString != null) {
      try {
        return json.decode(dataString) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  /// Clear MHP profile cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  /// Get specific field from cache
  static Future<T?> getField<T>(String key) async {
    final data = await getProfileData();
    return data[key] as T?;
  }

  /// Check if cache has data
  static Future<bool> hasData() async {
    final data = await getProfileData();
    return data.isNotEmpty;
  }
}

