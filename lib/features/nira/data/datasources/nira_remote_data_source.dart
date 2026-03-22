// data/datasources/nira_remote_data_source.dart
// NIRA API paths must match fly-be: pkg/nira/constant.go (basePath) and handler.go (routes).
// Backend basePath = "nira/external/v1". Full URLs = ApiClient.baseUrl + path.
//
// Backend (fly-be/pkg/nira/handler.go)     -> Flutter path
// POST  nira/external/v1/chat              -> $_basePath/chat
// GET   nira/external/v1/messages/:id      -> $_basePath/messages/$sessionId
// GET   nira/external/v1/session/active   -> $_basePath/session/active
// GET   nira/external/v1/session/:id      -> $_basePath/session/$sessionId
// PATCH nira/external/v1/session/end/:id  -> $_basePath/session/end/$sessionId
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/nira_message_model.dart';
import '../models/nira_session_model.dart';

abstract class NiraRemoteDataSource {
  Future<NiraMessageModel> sendMessage(String message);
  Future<List<NiraMessageModel>> getMessages(String sessionId);
  Future<NiraSessionModel?> getSession(String sessionId);
  Future<NiraSessionModel?> getActiveSession();
  Future<void> endSession(String sessionId);
}

class NiraRemoteDataSourceImpl implements NiraRemoteDataSource {
  final Dio client;

  NiraRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  /// Must match fly-be/pkg/nira/constant.go basePath (with leading slash for Dio).
  static const String _basePath = '/nira/external/v1';

  @override
  Future<NiraMessageModel> sendMessage(String message) async {
    try {
      final response = await client.post(
        '$_basePath/chat',
        queryParameters: {'message': message},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return NiraMessageModel.fromJson(payload);
        }
      }
      throw ServerException(
        'Invalid response from NIRA chat',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
    throw ServerException('Failed to send message');
  }

  @override
  Future<List<NiraMessageModel>> getMessages(String sessionId) async {
    try {
      final response = await client.get('$_basePath/messages/$sessionId');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => NiraMessageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      throw ServerException(
        'Invalid response from NIRA messages',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
    throw ServerException('Failed to fetch messages');
  }

  @override
  Future<NiraSessionModel?> getSession(String sessionId) async {
    try {
      final response = await client.get('$_basePath/session/$sessionId');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return NiraSessionModel.fromJson(payload);
        }
      }
      throw ServerException(
        'Invalid response from NIRA session',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
    throw ServerException('Failed to fetch session');
  }

  @override
  Future<NiraSessionModel?> getActiveSession() async {
    try {
      final response = await client.get('$_basePath/session/active');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final payload = data['data'];
        if (payload == null) return null;
        if (payload is Map<String, dynamic>) {
          return NiraSessionModel.fromJson(payload);
        }
      }
      return null;
    } on DioException catch (e) {
      _handleDioException(e);
    }
    throw ServerException('Failed to fetch active session');
  }

  @override
  Future<void> endSession(String sessionId) async {
    try {
      final response = await client.patch('$_basePath/session/end/$sessionId');
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to end session',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException(
        'Connection timeout. Please check your internet connection.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException(
        'No internet connection. Please check your network.',
      );
    }
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String msg = 'Request failed';
      if (data is Map<String, dynamic> && data.containsKey('msg')) {
        final m = data['msg'];
        if (m is String) msg = m;
      }
      throw ServerException(msg, statusCode: statusCode);
    }
    throw NetworkException(e.message ?? 'Network error');
  }
}
