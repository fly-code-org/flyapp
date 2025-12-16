import 'package:flutter/material.dart';
import 'package:fly/core/widgets/bottom_navbar.dart';
import 'package:get/get.dart';
import '../../controller/notification_controller.dart';
import '../widget/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch mock data (simulate API)
    controller.fetchNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all') controller.markAllAsRead();
              if (value == 'clear_all') controller.clearAll();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'mark_all', child: Text('Mark all as read')),
              PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No notifications yet",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return NotificationCard(
                notification: notif,
                onTap: () {
                  controller.markAsRead(notif.id);
                  // TODO: handle navigation based on notif type later
                },
              );
            },
          ),
        );
      }),
    );
  }
}
