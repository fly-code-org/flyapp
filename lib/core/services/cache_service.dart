import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration? maxAge;

  CacheEntry({
    required this.data,
    required this.cachedAt,
    this.maxAge,
  });

  bool get isExpired {
    if (maxAge == null) return false;
    return DateTime.now().difference(cachedAt) > maxAge!;
  }

  bool get isStale {
    const staleThreshold = Duration(minutes: 5);
    return DateTime.now().difference(cachedAt) > staleThreshold;
  }

  Map<String, dynamic> toJson(dynamic Function(T) dataToJson) => {
        'data': dataToJson(data),
        'cachedAt': cachedAt.toIso8601String(),
        'maxAgeMs': maxAge?.inMilliseconds,
      };

  static CacheEntry<T>? fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) dataFromJson,
  ) {
    try {
      return CacheEntry<T>(
        data: dataFromJson(json['data']),
        cachedAt: DateTime.parse(json['cachedAt'] as String),
        maxAge: json['maxAgeMs'] != null
            ? Duration(milliseconds: json['maxAgeMs'] as int)
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}

class CacheService {
  static CacheService? _instance;
  static SharedPreferences? _prefs;

  CacheService._();

  static Future<CacheService> getInstance() async {
    _instance ??= CacheService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static const _prefix = 'cache_';

  String _key(String key) => '$_prefix$key';

  Future<void> set<T>(
    String key,
    T data, {
    Duration? maxAge,
    dynamic Function(T)? toJson,
  }) async {
    final entry = CacheEntry<T>(
      data: data,
      cachedAt: DateTime.now(),
      maxAge: maxAge,
    );

    final jsonData = entry.toJson(toJson ?? (d) => d);
    await _prefs?.setString(_key(key), jsonEncode(jsonData));
  }

  CacheEntry<T>? get<T>(
    String key, {
    T Function(dynamic)? fromJson,
  }) {
    final raw = _prefs?.getString(_key(key));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntry.fromJson<T>(json, fromJson ?? (d) => d as T);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(_key(key));
  }

  Future<void> clear() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith(_prefix)) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  Future<void> clearExpired() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith(_prefix)) ?? [];
    for (final key in keys) {
      final raw = _prefs?.getString(key);
      if (raw == null) continue;

      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(json['cachedAt'] as String);
        final maxAgeMs = json['maxAgeMs'] as int?;

        if (maxAgeMs != null) {
          final maxAge = Duration(milliseconds: maxAgeMs);
          if (DateTime.now().difference(cachedAt) > maxAge) {
            await _prefs?.remove(key);
          }
        }
      } catch (_) {
        await _prefs?.remove(key);
      }
    }
  }
}

class CacheKeys {
  static const userProfile = 'user_profile';
  static const mhpProfile = 'mhp_profile';
  static const communityFeed = 'community_feed';
  static const journals = 'journals';
  static const notifications = 'notifications';
  static const homeData = 'home_data';

  static String userProfileById(String id) => 'user_profile_$id';
  static String mhpProfileById(String id) => 'mhp_profile_$id';
  static String communityById(String id) => 'community_$id';
  static String postById(String id) => 'post_$id';
}
