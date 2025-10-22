import 'package:get/get.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchNotifications() async {
    isLoading.value = true;

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake hardcoded response
    final List<NotificationModel> fakeData = [
      NotificationModel(
        id: '1',
        title: 'Welcome to Fly!',
        message: 'Thanks for joining our community.',
        senderImage: 'https://cdn-icons-png.flaticon.com/512/147/147144.png',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Weekly Update',
        message: 'New mindful sessions are available now!',
        senderImage: 'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Community Post',
        message: 'John Doe shared a new post in Mindful Living.',
        senderImage: 'https://cdn-icons-png.flaticon.com/512/706/706830.png',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    notifications.assignAll(fakeData);
    isLoading.value = false;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  void clearAll() {
    notifications.clear();
  }
}
