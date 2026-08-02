import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<PushNotificationService> init() async {
    await _requestPermission();
    await _getToken();
    _setupMessageHandlers();
    return this;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('FCM permission status: ${settings.authorizationStatus}');
    }
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      if (_fcmToken != null) {
        await _registerTokenWithBackend(_fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _registerTokenWithBackend(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await ApiClient.refreshToken();
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiClient.dio.post('/api/device-token', data: {
        'token': token,
        'platform': platform,
      });
      if (kDebugMode) {
        print('FCM token registered with backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token: $e');
      }
    }
  }

  Future<void> unregisterToken() async {
    if (_fcmToken == null) return;

    try {
      await ApiClient.refreshToken();
      await ApiClient.dio.delete('/api/device-token', data: {
        'token': _fcmToken,
      });
      if (kDebugMode) {
        print('FCM token unregistered from backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering FCM token: $e');
      }
    }
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a terminated state via notification
    _checkInitialMessage();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }

    // Refresh notification count in the app
    _refreshNotificationCount();
  }

  void _handleMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Message tap: ${message.data}');
    }
    _navigateFromNotification(message.data);
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromNotification(initialMessage.data);
    }
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final postId = data['post_id'] as String?;
    final commentId = data['comment_id'] as String?;

    if (type == null) return;

    switch (type) {
      case 'post_like':
      case 'followed_tag_post':
        if (postId != null) {
          Get.toNamed('/post/$postId');
        }
        break;
      case 'post_comment':
      case 'comment_reply':
        if (postId != null) {
          // Navigate to post with comment section open
          Get.toNamed('/post/$postId', arguments: {'scrollToComment': commentId});
        }
        break;
    }
  }

  void _refreshNotificationCount() {
    // Try to update notification controller if it exists
    try {
      final notifController = Get.find<dynamic>(tag: 'NotificationController');
      notifController.fetchUnreadCount();
    } catch (_) {
      // Controller not registered yet, ignore
    }
  }
}
