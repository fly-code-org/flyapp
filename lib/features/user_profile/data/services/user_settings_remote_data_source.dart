import 'package:dio/dio.dart';
import 'package:fly/core/network/api_client.dart';

class UserSettingsRemoteDataSource {
  final Dio _client;
  UserSettingsRemoteDataSource({Dio? dio}) : _client = dio ?? ApiClient.dio;

  // ── Profile ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final r = await _client.get('/users/external/v1/profile');
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    await _client.patch('/users/external/v1/profile', data: body);
  }

  // ── Password ──────────────────────────────────────────────────────────────

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _client.patch('/users/external/v1/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // ── Block ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    final r = await _client.get('/users/external/v1/blocked');
    final data = (r.data as Map<String, dynamic>)['data'];
    if (data == null) return [];
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> blockUser(String targetId) async {
    await _client.post('/users/external/v1/block/$targetId');
  }

  Future<void> unblockUser(String targetId) async {
    await _client.delete('/users/external/v1/block/$targetId');
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSessions({required String status}) async {
    final r = await _client.get(
      '/connect/external/v1/seeker/bookings',
      queryParameters: {'status': status},
    );
    final data = (r.data as Map<String, dynamic>)['data'];
    if (data == null) return [];
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> cancelSession(String bookingId) async {
    await _client.post('/connect/external/v1/bookings/$bookingId/cancel');
  }

  // ── Payment History ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPaymentHistory() async {
    final r = await _client.get('/connect/external/v1/seeker/payment-history');
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ── Tags (Preferences) ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final r = await _client.get('/community/external/v1/tag');
    final data = (r.data as Map<String, dynamic>)['data'];
    if (data == null) return [];
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveInterests(List<Map<String, dynamic>> tags) async {
    await _client.post('/users/external/v1/interests', data: {
      'tags': tags,
      'communities': <String>[],
    });
  }

  // ── Contact ───────────────────────────────────────────────────────────────

  Future<void> sendContactMessage(String subject, String message) async {
    await _client.post('/users/external/v1/contact', data: {
      'subject': subject,
      'message': message,
    });
  }
}
