import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';

class ProfileUpdateService {
  final Dio client;

  ProfileUpdateService({Dio? dio}) : client = dio ?? ApiClient.dio;

  Future<bool> updateProfilePicture(String picturePath) async {
    try {
      print('🔄 [PROFILE UPDATE] Updating profile picture: $picturePath');

      final response = await client.patch(
        '/users/external/v1/profile',
        data: {
          'picture_path': picturePath,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [PROFILE UPDATE] Profile picture updated successfully');
        return true;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
