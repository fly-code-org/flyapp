// data/datasources/mhp_profile_remote_data_source.dart
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../streak/data/streak_patch_result.dart';
import '../models/mhp_profile_response_model.dart';

abstract class MhpProfileRemoteDataSource {
  Future<MhpProfileResponseModel> createProfile({
    required Map<String, dynamic> profileData,
  });
  Future<Map<String, dynamic>> getMhpProfile();
  /// GET /mhp/external/v1/profile/:userId (another MHP, viewer).
  Future<Map<String, dynamic>> getMhpProfileByUserId(String userId);
  Future<Map<String, dynamic>> getAboutMe();
  Future<void> updateAboutMe(Map<String, dynamic> body);
  Future<void> updateConnect(Map<String, dynamic> body);
  /// PATCH /mhp/external/v1/google?token= — exchange serverAuthCode, store Calendar tokens.
  Future<void> linkGoogleCalendar({required String serverAuthCode});
  /// GET /mhp/external/v1/booked-sessions — MHP merged Connect + therapy sessions.
  Future<Map<String, dynamic>> getBookedSessions({int skip = 0, int limit = 20});
  Future<StreakPatchResult?> updateStreak();
  // Settings
  Future<Map<String, dynamic>> getAvailability();
  Future<Map<String, dynamic>> getSessionPreferences();
  Future<void> updateSessionPreferences(Map<String, dynamic> body);
  Future<Map<String, dynamic>> getConsultationFees();
  Future<void> updateConsultationFees(Map<String, dynamic> body);
  Future<Map<String, dynamic>> getPaymentMethod();
  Future<void> updatePaymentMethod(Map<String, dynamic> body);
  Future<List<String>> searchSpecializations(String query);
  Future<void> updateSpecializations(List<String> specializations);
  Future<Map<String, dynamic>> getInvoices();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> updateProfile(Map<String, dynamic> body);
}

class MhpProfileRemoteDataSourceImpl implements MhpProfileRemoteDataSource {
  final Dio client;
  MhpProfileRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<MhpProfileResponseModel> createProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      print('🔐 Starting MHP profile creation API call');
      print('📦 Profile Data: $profileData');

      final response = await client.post(
        '/mhp/external/v1/profile',
        data: profileData,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 MHP Profile API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          print(
            '❌ Response is not a Map. Actual type: ${response.data.runtimeType}',
          );
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}. Response: ${response.data}',
          );
        }

        return MhpProfileResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in MHP profile creation: ${e.type}');
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
              if (msgMap.containsKey('err')) {
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

  @override
  Future<Map<String, dynamic>> getMhpProfile() async {
    try {
      final response = await client.get(
        '/mhp/external/v1/profile',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      throw ServerException(
        'Unexpected status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to get MHP profile',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMhpProfileByUserId(String userId) async {
    try {
      final response = await client.get(
        '/mhp/external/v1/profile/$userId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      throw ServerException(
        'Unexpected status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to load MHP profile',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getAboutMe() async {
    try {
      final response = await client.get(
        '/mhp/external/v1/aboutme',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      throw ServerException(
        'Unexpected status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to get about me',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<void> updateAboutMe(Map<String, dynamic> body) async {
    try {
      final response = await client.patch(
        '/mhp/external/v1/aboutme',
        data: body,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to update about me',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to update about me',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<void> updateConnect(Map<String, dynamic> body) async {
    try {
      final response = await client.patch(
        '/mhp/external/v1/connect',
        data: body,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to update connect',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to update connect',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<void> linkGoogleCalendar({required String serverAuthCode}) async {
    if (kDebugMode) {
      final jwtLen = ApiClient.getAuthToken()?.length ?? 0;
      developer.log(
        'PATCH /mhp/external/v1/google: googleCodeLen=${serverAuthCode.length} '
        'flyJwtCachedLen=$jwtLen baseUrl=${client.options.baseUrl}',
        name: 'MhpProfileRemote',
      );
    }
    try {
      final response = await client.patch(
        '/mhp/external/v1/google',
        queryParameters: {'token': serverAuthCode},
      );
      if (response.statusCode == 200) return;
      throw ServerException(
        'Failed to link Google Calendar',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        developer.log(
          'linkGoogleCalendar DioException: ${e.type} status=${e.response?.statusCode} '
          'data=${e.response?.data}',
          name: 'MhpProfileRemote',
          error: e,
        );
      }
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        var errorMessage = 'Failed to link Google Calendar';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is String && msg.isNotEmpty) {
              errorMessage = msg;
            } else if (msg is Map) {
              for (final entry in msg.entries) {
                final v = entry.value;
                if (v is String && v.isNotEmpty) {
                  errorMessage = v;
                  break;
                }
              }
            }
          } else if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            errorMessage = responseData['error'] as String;
          }
        }
        if (statusCode == 401) {
          errorMessage =
              '$errorMessage If this keeps happening, sign in again and ensure '
              'API_BASE_URL points at the same server that issued your session.';
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getBookedSessions({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await client.get(
        '/mhp/external/v1/booked-sessions',
        queryParameters: {'skip': skip, 'limit': limit},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException(
        'Unexpected status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          'Failed to load sessions',
          statusCode: e.response!.statusCode,
        );
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> _getData(String path) async {
    try {
      final response = await client.get(path,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final d = response.data as Map<String, dynamic>;
        return (d['data'] is Map<String, dynamic>)
            ? d['data'] as Map<String, dynamic>
            : d;
      }
      throw ServerException('Unexpected status: ${response.statusCode}',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Request failed', statusCode: e.response!.statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  Future<void> _patchData(String path, Map<String, dynamic> body) async {
    try {
      final response = await client.patch(path,
          data: body,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode != 200) {
        throw ServerException('Request failed', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Request failed', statusCode: e.response!.statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getAvailability() => _getData('/mhp/external/v1/availability');

  @override
  Future<Map<String, dynamic>> getSessionPreferences() =>
      _getData('/mhp/external/v1/session-preferences');

  @override
  Future<void> updateSessionPreferences(Map<String, dynamic> body) =>
      _patchData('/mhp/external/v1/session-preferences', body);

  @override
  Future<Map<String, dynamic>> getConsultationFees() =>
      _getData('/mhp/external/v1/consultation-fees');

  @override
  Future<void> updateConsultationFees(Map<String, dynamic> body) =>
      _patchData('/mhp/external/v1/consultation-fees', body);

  @override
  Future<Map<String, dynamic>> getPaymentMethod() =>
      _getData('/mhp/external/v1/payment-method');

  @override
  Future<void> updatePaymentMethod(Map<String, dynamic> body) =>
      _patchData('/mhp/external/v1/payment-method', body);

  @override
  Future<List<String>> searchSpecializations(String query) async {
    try {
      final response = await client.get(
        '/mhp/external/v1/specializations/search',
        queryParameters: {'q': query},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final d = response.data as Map<String, dynamic>;
        final data = d['data'];
        if (data is List) return data.cast<String>();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateSpecializations(List<String> specializations) =>
      _patchData('/mhp/external/v1/specializations', {'specializations': specializations});

  @override
  Future<Map<String, dynamic>> getInvoices() async {
    try {
      final response = await client.get('/mhp/external/v1/invoices',
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final d = response.data as Map<String, dynamic>;
        return (d['data'] is Map<String, dynamic>)
            ? d['data'] as Map<String, dynamic>
            : {'total_earned_inr': 0, 'this_month_inr': 0, 'items': []};
      }
      return {'total_earned_inr': 0, 'this_month_inr': 0, 'items': []};
    } on DioException catch (_) {
      return {'total_earned_inr': 0, 'this_month_inr': 0, 'items': []};
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await client.patch(
        '/users/external/v1/change-password',
        data: {'current_password': currentPassword, 'new_password': newPassword},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to change password', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final body = e.response!.data;
        var msg = 'Failed to change password';
        if (body is Map && body['msg'] is Map) {
          msg = (body['msg'] as Map)['err']?.toString() ?? msg;
        }
        throw ServerException(msg, statusCode: e.response!.statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> body) async {
    try {
      await client.patch(
        '/mhp/external/v1/profile',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final b = e.response!.data;
        var msg = 'Failed to update profile';
        if (b is Map && b['msg'] is String) msg = b['msg'] as String;
        throw ServerException(msg, statusCode: e.response!.statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }

  @override
  Future<StreakPatchResult?> updateStreak() async {
    try {
      final offset = DateTime.now().timeZoneOffset.inMinutes;
      final response = await client.patch(
        '/mhp/external/v1/streaks',
        queryParameters: {'offset_minutes': offset},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            return StreakPatchResult.fromJson(data);
          }
        }
        return null;
      }
      throw ServerException(
        'Unexpected status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        var errorMessage = 'Failed to update streak';
        if (responseData is Map<String, dynamic> &&
            responseData['msg'] is Map) {
          final msg = responseData['msg'] as Map<String, dynamic>;
          errorMessage =
              (msg['err'] ?? msg['err: '] ?? errorMessage).toString();
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      }
      throw NetworkException('Network error: ${e.message}');
    }
  }
}

