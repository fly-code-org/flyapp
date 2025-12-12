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
}

