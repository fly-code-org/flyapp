// data/datasources/comment_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/comment_model.dart';
import '../models/create_comment_request_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getCommentsByPostId(String postId);
  Future<List<CommentModel>> getRepliesByCommentId(String commentId);
  Future<void> createComment(CreateCommentRequestModel request);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final Dio client;

  CommentRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    try {
      print('💬 [COMMENT API] Fetching comments for post ID: $postId');

      final response = await client.get(
        '/post/external/v1/comment/$postId',
      );

      print('📦 [COMMENT API] Response Status: ${response.statusCode}');
      print('📦 [COMMENT API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            final comments = data
                .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
                .toList();
            print('✅ [COMMENT API] Fetched ${comments.length} comments');
            return comments;
          }
        }
        throw ServerException('Invalid response format', statusCode: 200);
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMENT API] DioException: ${e.type}');
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
        String errorMessage = 'Failed to fetch comments';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
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

  @override
  Future<List<CommentModel>> getRepliesByCommentId(String commentId) async {
    try {
      print('💬 [COMMENT API] Fetching replies for comment ID: $commentId');

      final response = await client.get(
        '/post/external/v1/comment/parent/$commentId',
      );

      print('📦 [COMMENT API] Response Status: ${response.statusCode}');
      print('📦 [COMMENT API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            final replies = data
                .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
                .toList();
            print('✅ [COMMENT API] Fetched ${replies.length} replies');
            return replies;
          }
        }
        throw ServerException('Invalid response format', statusCode: 200);
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMENT API] DioException: ${e.type}');
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
        String errorMessage = 'Failed to fetch replies';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
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

  @override
  Future<void> createComment(CreateCommentRequestModel request) async {
    try {
      print('💬 [COMMENT API] Creating comment...');
      print('   - Post ID: ${request.postId}');
      print('   - Parent Comment ID: ${request.parentCommentId ?? "null"}');
      print('   - Text: ${request.text}');

      final requestData = request.toJson();
      print('📤 [COMMENT API] Request data: $requestData');

      final response = await client.post(
        '/post/external/v1/comment',
        data: requestData,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [COMMENT API] Response Status: ${response.statusCode}');
      print('📦 [COMMENT API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [COMMENT API] Comment created successfully');
        return;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [COMMENT API] DioException: ${e.type}');
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
        String errorMessage = 'Failed to create comment';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
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
