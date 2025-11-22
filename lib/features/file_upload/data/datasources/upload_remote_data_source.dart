// data/datasources/upload_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/presigned_url_response_model.dart';

abstract class UploadRemoteDataSource {
  Future<PresignedUrlResponseModel> getPresignedUrl({
    required String fileType,
    required String fileName,
    required String contentType,
  });
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final Dio client;
  UploadRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<PresignedUrlResponseModel> getPresignedUrl({
    required String fileType,
    required String fileName,
    required String contentType,
  }) async {
    try {
      print('🔐 Starting presigned URL request');
      print('📦 Request Query Parameters:');
      print('   - type: $fileType');
      print('   - file-name: $fileName');

      final response = await client.get(
        '/s3store/external/v1/presigned-url',
        queryParameters: {'type': fileType, 'file-name': fileName},
      );

      print('📦 Presigned URL API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        return PresignedUrlResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in presigned URL request: ${e.type}');
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
          if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            errorMessage = responseData['error'] as String;
          } else if (responseData.containsKey('msg')) {
            if (responseData['msg'] is Map) {
              final msgMap = responseData['msg'] as Map<String, dynamic>;
              if (msgMap.containsKey('error')) {
                errorMessage = msgMap['error'] as String;
              } else if (msgMap.containsKey('err')) {
                errorMessage = msgMap['err'] as String;
              } else if (msgMap.containsKey('err: ')) {
                errorMessage = msgMap['err: '] as String;
              } else {
                for (final key in msgMap.keys) {
                  if (key.toString().trim().startsWith('err')) {
                    errorMessage = msgMap[key] as String;
                    break;
                  }
                }
              }
            } else if (responseData['msg'] is String) {
              errorMessage = responseData['msg'] as String;
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
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
