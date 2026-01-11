// data/services/profile_update_service.dart
// Service for updating user profile
// TODO: Implement when PATCH /users/external/v1/profile endpoint is available

import 'package:dio/dio.dart';
// import '../../../../core/error/exceptions.dart'; // Uncommented when implementing
import '../../../../core/network/api_client.dart';

class ProfileUpdateService {
  final Dio client;

  ProfileUpdateService({Dio? dio}) : client = dio ?? ApiClient.dio;

  /// Update user profile picture path
  /// 
  /// This method will be implemented once the backend endpoint is available.
  /// Expected endpoint: PATCH /users/external/v1/profile
  /// Expected payload: {"picture_path": "/assets/profile_X.svg"}
  /// 
  /// Returns true if successful, throws exception on error
  Future<bool> updateProfilePicture(String picturePath) async {
    // TODO: Implement when PATCH endpoint is available
    // Example implementation:
    /*
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
    */
    
    // Placeholder implementation - just log that it would be saved
    print('⚠️ [PROFILE UPDATE] Profile picture update endpoint not yet available');
    print('   Would save picture_path: $picturePath');
    print('   TODO: Implement PATCH /users/external/v1/profile endpoint');
    
    // Return false to indicate it wasn't actually saved
    return false;
  }
}
