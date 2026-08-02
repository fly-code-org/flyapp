import 'dart:math';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ProfilePictureItem {
  final int id;
  final String path;
  final String url;

  ProfilePictureItem({
    required this.id,
    required this.path,
    required this.url,
  });

  factory ProfilePictureItem.fromJson(Map<String, dynamic> json) {
    return ProfilePictureItem(
      id: json['id'] as int,
      path: json['path'] as String,
      url: json['url'] as String,
    );
  }
}

class ProfilePicturesService {
  final Dio _client;
  List<ProfilePictureItem>? _cachedPictures;

  ProfilePicturesService({Dio? dio}) : _client = dio ?? ApiClient.dio;

  Future<List<ProfilePictureItem>> getProfilePictures() async {
    if (_cachedPictures != null) {
      return _cachedPictures!;
    }

    try {
      final response = await _client.get(
        '/users/external/v1/profile-pictures',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>;
        _cachedPictures = data
            .map((item) => ProfilePictureItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedPictures!;
      }
      return [];
    } catch (e) {
      print('❌ [PROFILE_PICTURES] Error fetching profile pictures: $e');
      return [];
    }
  }

  ProfilePictureItem? getRandomPicture(String seed) {
    if (_cachedPictures == null || _cachedPictures!.isEmpty) {
      return null;
    }
    final random = Random(seed.hashCode);
    final index = random.nextInt(_cachedPictures!.length);
    return _cachedPictures![index];
  }

  void clearCache() {
    _cachedPictures = null;
  }
}
