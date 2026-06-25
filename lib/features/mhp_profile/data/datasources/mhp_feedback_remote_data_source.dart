import 'package:dio/dio.dart';
import 'package:fly/core/error/exceptions.dart';
import 'package:fly/core/network/api_client.dart';

class MhpFeedbackRemoteDataSource {
  MhpFeedbackRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['msg'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is Map) {
        for (final entry in msg.entries) {
          final v = entry.value;
          if (v is String && v.isNotEmpty) return v;
        }
      }
    }
    return e.message ?? 'Request failed';
  }

  Never _throwDio(DioException e) {
    final code = e.response?.statusCode;
    final msg = _messageFromDio(e);
    if (code == 409) throw ServerException('You have already reviewed this session.', statusCode: code);
    if (code == 401 || code == 403) throw AuthException(msg);
    throw ServerException(msg, statusCode: code);
  }

  Future<void> submitFeedback({
    required String mhpId,
    required String bookingId,
    required int rating,
    required String text,
  }) async {
    try {
      await _dio.post(
        '/mhp/feedback',
        data: {
          'mhp_id': mhpId,
          'booking_id': bookingId,
          'rating': rating,
          'text': text,
        },
      );
    } on DioException catch (e) {
      _throwDio(e);
    }
  }
}
