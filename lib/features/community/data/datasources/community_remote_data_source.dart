// data/datasources/community_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/community_model.dart';

abstract class CommunityRemoteDataSource {
  Future<CreateCommunityResponseModel> createCommunity(
    CreateCommunityRequestModel request,
  );
  Future<List<CommunityModel>> getCommunitiesByType(String type);
  /// GET /community?created_by_type=mhp (or user). Returns current user's community or null if none.
  Future<CommunityModel?> getCommunity(String createdByType);
  /// GET /community/:id. Returns community by ID (for viewing any community).
  Future<CommunityModel?> getCommunityById(String communityId);
  /// PATCH /community?created_by_type=mhp. Body: name, description, logo_path, tag_id, guidelines_*.
  Future<void> updateCommunity(String createdByType, Map<String, dynamic> body);
  /// GET /tag. Returns list of tags (tag_id, name, icon_path, type).
  Future<List<Map<String, dynamic>>> getTags();
  Future<void> followCommunity(String communityId);
  Future<void> unfollowCommunity(String communityId);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final Dio client;

  CommunityRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<CreateCommunityResponseModel> createCommunity(
    CreateCommunityRequestModel request,
  ) async {
    try {
      print('💾 [COMMUNITY API] Creating community...');
      print('   - Name: ${request.name}');
      print('   - Type: ${request.type}');
      print('   - Tag ID: ${request.tagId}');

      final response = await client.post(
        '/community/external/v1/community',
        data: request.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [COMMUNITY API] Response Status: ${response.statusCode}');
      print('📦 [COMMUNITY API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        return CreateCommunityResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMUNITY API] DioException: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('msg')) {
          final msg = responseData['msg'];
          if (msg is Map && msg.containsKey('err: ')) {
            errorMessage = msg['err: '] as String;
          } else if (msg is String) {
            errorMessage = msg;
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<CommunityModel>> getCommunitiesByType(String type) async {
    try {
      print('🔍 [COMMUNITY API] Fetching communities by type...');
      print('   - Type: $type');

      final response = await client.get(
        '/community/external/v1/communities',
        queryParameters: {'type': type},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [COMMUNITY API] Response Status: ${response.statusCode}');
      print('📦 [COMMUNITY API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseModel = CommunitiesResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return responseModel.data;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMUNITY API] DioException: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('msg')) {
          final msg = responseData['msg'];
          if (msg is Map && msg.containsKey('err: ')) {
            errorMessage = msg['err: '] as String;
          } else if (msg is String) {
            errorMessage = msg;
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CommunityModel?> getCommunity(String createdByType) async {
    try {
      final response = await client.get(
        '/community/external/v1/community',
        queryParameters: {'created_by_type': createdByType},
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['data'];
        if (raw is Map<String, dynamic>) {
          return CommunityModel.fromJson(raw);
        }
        return null;
      }
      return null;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get community: $e');
    }
  }

  @override
  Future<CommunityModel?> getCommunityById(String communityId) async {
    try {
      final response = await client.get(
        '/community/external/v1/community/$communityId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['data'];
        if (raw is Map<String, dynamic>) {
          return CommunityModel.fromJson(raw);
        }
        return null;
      }
      return null;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get community by id: $e');
    }
  }

  @override
  Future<void> updateCommunity(String createdByType, Map<String, dynamic> body) async {
    try {
      final response = await client.patch(
        '/community/external/v1/community',
        queryParameters: {'created_by_type': createdByType},
        data: body,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to update community',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to update community',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    try {
      final response = await client.get(
        '/community/external/v1/tag',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['data'];
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      }
      return [];
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get tags: $e');
    }
  }

  @override
  Future<void> followCommunity(String communityId) async {
    try {
      print('👥 [COMMUNITY API] Following community...');
      print('   - Community ID: $communityId');

      final response = await client.post(
        '/community/external/v1/community/follow',
        data: {'community_id': communityId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [COMMUNITY API] Follow Response Status: ${response.statusCode}');
      print('📦 [COMMUNITY API] Follow Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMUNITY API] Follow DioException: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('msg')) {
          final msg = responseData['msg'];
          if (msg is Map && msg.containsKey('err: ')) {
            errorMessage = msg['err: '] as String;
          } else if (msg is String) {
            errorMessage = msg;
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> unfollowCommunity(String communityId) async {
    try {
      print('👥 [COMMUNITY API] Unfollowing community...');
      print('   - Community ID: $communityId');

      final response = await client.post(
        '/community/external/v1/community/unfollow',
        data: {'community_id': communityId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [COMMUNITY API] Unfollow Response Status: ${response.statusCode}');
      print('📦 [COMMUNITY API] Unfollow Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMUNITY API] Unfollow DioException: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('msg')) {
          final msg = responseData['msg'];
          if (msg is Map && msg.containsKey('err: ')) {
            errorMessage = msg['err: '] as String;
          } else if (msg is String) {
            errorMessage = msg;
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}



