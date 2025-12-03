import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/quiz_response_model.dart';
import '../models/answer_response_model.dart';

abstract class QuizRemoteDataSource {
  Future<QuizResponseModel> getQuizQuestions({
    required String category,
    List<String>? tags,
  });

  Future<AnswerResponseModel> submitAnswer({
    required String questionId,
    required String answer,
    String? optionId,
    List<String>? attachments,
  });
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio client;

  QuizRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<QuizResponseModel> getQuizQuestions({
    required String category,
    List<String>? tags,
  }) async {
    try {
      print('📋 [QUIZ API] Fetching questions...');
      print('   - Category: $category');
      print('   - Tags: $tags');

      // Build query parameters with multiple tags
      final queryParams = <String, dynamic>{
        'category': category,
      };

      // Add tags as query parameters (multiple tags with same key)
      // Dio handles List<String> by creating multiple query params with same key
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      print('📋 [QUIZ API] Query Parameters: $queryParams');

      final response = await client.get(
        '/users/external/v1/quiz',
        queryParameters: queryParams,
      );

      print('📦 [QUIZ API] Response Status: ${response.statusCode}');
      print('📦 [QUIZ API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        return QuizResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [QUIZ API] DioException: ${e.message}');
      if (e.response != null) {
        print('   - Status Code: ${e.response?.statusCode}');
        print('   - Response Data: ${e.response?.data}');

        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData['msg'] != null) {
            throw ServerException(
              errorData['msg'].toString(),
              statusCode: 400,
            );
          }
        }

        throw ServerException(
          e.response?.data?.toString() ?? 'Failed to fetch questions',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [QUIZ API] Unexpected error: $e');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AnswerResponseModel> submitAnswer({
    required String questionId,
    required String answer,
    String? optionId,
    List<String>? attachments,
  }) async {
    try {
      print('📤 [ANSWER API] Submitting answer...');
      print('   - Question ID: $questionId');
      print('   - Answer: $answer');
      print('   - Option ID: $optionId');
      print('   - Attachments: $attachments');

      final requestBody = <String, dynamic>{
        'question_id': questionId,
        'answer': answer,
      };

      if (optionId != null && optionId.isNotEmpty) {
        requestBody['option_id'] = optionId;
      }

      if (attachments != null && attachments.isNotEmpty) {
        requestBody['attachments'] = attachments;
      }

      final response = await client.post(
        '/users/external/v1/answer',
        data: requestBody,
      );

      print('📦 [ANSWER API] Response Status: ${response.statusCode}');
      print('📦 [ANSWER API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        return AnswerResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [ANSWER API] DioException: ${e.message}');
      if (e.response != null) {
        print('   - Status Code: ${e.response?.statusCode}');
        print('   - Response Data: ${e.response?.data}');

        if (e.response?.statusCode == 401) {
          throw AuthException('Authentication required. Please login again.');
        }

        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData['msg'] != null) {
            throw ServerException(
              errorData['msg'].toString(),
              statusCode: 400,
            );
          }
        }

        throw ServerException(
          e.response?.data?.toString() ?? 'Failed to submit answer',
          statusCode: e.response?.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [ANSWER API] Unexpected error: $e');
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Unexpected error: $e');
    }
  }
}

