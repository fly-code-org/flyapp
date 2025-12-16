// data/datasources/journal_remote_data_source.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/journal_model.dart';
import '../models/color_template_model.dart';

abstract class JournalRemoteDataSource {
  Future<List<JournalModel>> getJournals({int limit = 10, int skip = 0});
  Future<JournalModel> createJournal(Map<String, dynamic> journalData);
  Future<JournalModel> updateJournal(int journalId, Map<String, dynamic> journalData);
  Future<List<ColorTemplateModel>> getColorTemplates({int limit = 100, int skip = 0});
  Future<ColorTemplateModel> createColorTemplate(Map<String, dynamic> templateData);
}

class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  final Dio client;

  JournalRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<List<JournalModel>> getJournals({int limit = 10, int skip = 0}) async {
    try {
      print('🔍 [JOURNAL API] Fetching journals with limit=$limit, skip=$skip');
      
      final response = await client.get(
        '/journal/external/v1/journals',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      print('📦 [JOURNAL API] Response Status: ${response.statusCode}');
      print('📦 [JOURNAL API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Extract data from response: {"msg": "...", "data": [...]}
        List<dynamic> journalsList = [];
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'];
          // Handle null data (when no journals exist)
          if (data != null && data is List) {
            journalsList = data;
          } else if (data == null) {
            // No journals found, return empty list
            print('ℹ️ [JOURNAL API] No journals found (data is null)');
            return [];
          }
        } else if (responseData is List) {
          journalsList = responseData;
        }

        // If journalsList is still empty, return empty list
        if (journalsList.isEmpty) {
          print('ℹ️ [JOURNAL API] No journals found (empty list)');
          return [];
        }

        return journalsList
            .map((json) => JournalModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to fetch journals: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [JOURNAL API] DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException('Failed to fetch journals: ${e.response?.statusCode}');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [JOURNAL API] Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<JournalModel> createJournal(Map<String, dynamic> journalData) async {
    try {
      print('🔍 [JOURNAL API] Creating journal...');
      print('📤 [JOURNAL API] Request body: $journalData');
      print('📤 [JOURNAL API] Request body JSON: ${jsonEncode(journalData)}');
      
      final response = await client.post(
        '/journal/external/v1/',
        data: journalData,
      );

      print('📦 [JOURNAL API] Create Response Status: ${response.statusCode}');
      print('📦 [JOURNAL API] Create Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final responseData = response.data;
        
        // Extract journal ID from response
        int journalId = 0;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            if (data is int) {
              journalId = data;
            } else if (data is Map) {
              journalId = data['_id'] is int ? data['_id'] : int.tryParse(data['_id'].toString()) ?? 0;
            }
          }
        }

        // Fetch the created journal to return full data
        final journals = await getJournals(limit: 1, skip: 0);
        final createdJournal = journals.firstWhere(
          (j) => j.id == journalId,
          orElse: () => JournalModel(
            id: journalId,
            userId: '',
            title: journalData['title'] ?? '',
            content: journalData['content'] ?? '',
            colorTemplate: journalData['color_template_id'],
            mood: journalData['mood'],
            tags: (journalData['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return createdJournal;
      } else {
        throw ServerException('Failed to create journal: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [JOURNAL API] DioException: ${e.message}');
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMsg = errorData is Map ? errorData['msg'] : 'Failed to create journal';
        throw ServerException(errorMsg.toString());
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [JOURNAL API] Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<ColorTemplateModel>> getColorTemplates({int limit = 100, int skip = 0}) async {
    try {
      print('🔍 [JOURNAL API] Fetching color templates from journal.template collection...');
      print('🔍 [JOURNAL API] Request: GET /journal/external/v1/color-templates?limit=$limit&skip=$skip');
      
      final response = await client.get(
        '/journal/external/v1/color-templates',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      print('📦 [JOURNAL API] Color Templates Response Status: ${response.statusCode}');
      print('📦 [JOURNAL API] Color Templates Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Extract data from response: {"msg": "...", "data": [...]}
        List<dynamic> templatesList = [];
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'];
          // Handle null data (when no templates exist)
          if (data != null && data is List) {
            templatesList = data;
          } else if (data == null) {
            // No templates found, return empty list
            print('ℹ️ [JOURNAL API] No color templates found (data is null)');
            return [];
          }
        } else if (responseData is List) {
          templatesList = responseData;
        }

        // If templatesList is still empty, return empty list
        if (templatesList.isEmpty) {
          print('ℹ️ [JOURNAL API] No color templates found in journal.template collection (empty list)');
          return [];
        }

        print('✅ [JOURNAL API] Successfully fetched ${templatesList.length} color templates from journal.template collection');
        final templates = templatesList
            .map((json) => ColorTemplateModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Log template details for debugging
        for (var template in templates) {
          print('  📋 Template: id=${template.id}, hex=${template.hexCode}');
        }
        
        return templates;
      } else {
        throw ServerException('Failed to fetch color templates: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [JOURNAL API] DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException('Failed to fetch color templates: ${e.response?.statusCode}');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [JOURNAL API] Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<JournalModel> updateJournal(int journalId, Map<String, dynamic> journalData) async {
    try {
      print('🔍 [JOURNAL API] Updating journal $journalId...');
      print('📤 [JOURNAL API] Request body: $journalData');
      print('📤 [JOURNAL API] Request body JSON: ${jsonEncode(journalData)}');
      
      // Use journalData as-is (backend now accepts color_template_id as string)
      final updateData = Map<String, dynamic>.from(journalData);
      
      final response = await client.patch(
        '/journal/external/v1/$journalId',
        data: updateData,
      );

      print('📦 [JOURNAL API] Update Response Status: ${response.statusCode}');
      print('📦 [JOURNAL API] Update Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Fetch updated journal
        final journals = await getJournals(limit: 100, skip: 0);
        final updatedJournal = journals.firstWhere(
          (j) => j.id == journalId,
          orElse: () => throw ServerException('Journal not found after update'),
        );

        return updatedJournal;
      } else {
        throw ServerException('Failed to update journal: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [JOURNAL API] DioException: ${e.message}');
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMsg = errorData is Map ? errorData['msg'] : 'Failed to update journal';
        throw ServerException(errorMsg.toString());
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [JOURNAL API] Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<ColorTemplateModel> createColorTemplate(Map<String, dynamic> templateData) async {
    try {
      print('🔍 [JOURNAL API] Creating color template: $templateData');
      
      final response = await client.post(
        '/journal/external/v1/color-template',
        data: templateData,
      );

      print('📦 [JOURNAL API] Create Color Template Response Status: ${response.statusCode}');
      print('📦 [JOURNAL API] Create Color Template Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final responseData = response.data;
        
        // Extract template ID from response
        String templateId = '';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            templateId = responseData['data'].toString();
          }
        }

        // Return created template
        return ColorTemplateModel(
          id: templateId,
          hexCode: templateData['hex_code'] ?? '',
          moodSuggestion: templateData['mood_suggestion']?.toString(),
          label: templateData['label']?.toString(),
          emoji: templateData['emoji']?.toString(),
          description: templateData['description']?.toString(),
        );
      } else {
        throw ServerException('Failed to create color template: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [JOURNAL API] DioException: ${e.message}');
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMsg = errorData is Map ? errorData['msg'] : 'Failed to create color template';
        throw ServerException(errorMsg.toString());
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ [JOURNAL API] Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}

