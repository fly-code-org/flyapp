import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../model/notification_model.dart';
import '../../../core/network/api_client.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt unreadCount = 0.obs;

  static const int _pageSize = 20;
  int _skip = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  Future<void> fetchNotifications() async {
    if (isLoading.value) return;
    isLoading.value = true;
    _skip = 0;
    hasMore.value = true;

    try {
      await ApiClient.refreshToken();
      final res = await ApiClient.dio.get(
        '/api/notifications',
        queryParameters: {'skip': 0, 'limit': _pageSize},
      );
      final data = res.data as Map<String, dynamic>;
      final list = (data['notifications'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifications.assignAll(list);
      unreadCount.value = (data['unread_count'] as int?) ?? 0;
      _skip = list.length;
      hasMore.value = list.length == _pageSize;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message ?? 'Failed to load';
      Get.snackbar('Error', msg.toString(), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    try {
      await ApiClient.refreshToken();
      final res = await ApiClient.dio.get(
        '/api/notifications',
        queryParameters: {'skip': _skip, 'limit': _pageSize},
      );
      final data = res.data as Map<String, dynamic>;
      final list = (data['notifications'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifications.addAll(list);
      _skip += list.length;
      hasMore.value = list.length == _pageSize;
    } catch (_) {
      // silently fail on pagination
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      await ApiClient.refreshToken();
      final res = await ApiClient.dio.get('/api/notifications/unread-count');
      unreadCount.value = (res.data['unread_count'] as int?) ?? 0;
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || notifications[idx].isRead) return;
    notifications[idx].isRead = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    try {
      await ApiClient.refreshToken();
      await ApiClient.dio.patch('/api/notifications/$id/read');
    } catch (_) {
      notifications[idx].isRead = false;
      notifications.refresh();
      unreadCount.value++;
    }
  }

  Future<void> markAllAsRead() async {
    final hadUnread = notifications.any((n) => !n.isRead);
    if (!hadUnread) return;
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;

    try {
      await ApiClient.refreshToken();
      await ApiClient.dio.patch('/api/notifications/read-all');
    } catch (_) {
      fetchNotifications();
    }
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
  }
}
