import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'api_constants.dart';
import 'api_service.dart';

/// Notification types matching backend `notification_type` field.
enum NotifType { approved, assigned, rejected }

// ── AppNotification ────────────────────────────────────────────────────────
class AppNotification {
  final String   id;
  final String   message;
  final String   createdAt;
  final NotifType type;
  final bool     isRead;

  const AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j, {String? id}) =>
      AppNotification(
        id:        id ?? j['id']?.toString()
                       ?? DateTime.now().millisecondsSinceEpoch.toString(),
        message:   j['message']?.toString()   ?? '',
        createdAt: j['created_at']?.toString() ?? '',
        type:      _parseType(j['notification_type']?.toString() ?? ''),
        isRead:    j['is_read'] == true,
      );

  static NotifType _parseType(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'approved': return NotifType.approved;
      case 'assigned': return NotifType.assigned;
      case 'rejected': return NotifType.rejected;
      default:         return NotifType.approved;
    }
  }

  String get title {
    switch (type) {
      case NotifType.approved: return '✅ Request Approved';
      case NotifType.assigned: return '📦 Ready for Pickup';
      case NotifType.rejected: return '❌ Request Rejected';
    }
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
      id: id, message: message, createdAt: createdAt,
      type: type, isRead: isRead ?? this.isRead);
}

// ── NotificationService ────────────────────────────────────────────────────
class NotificationService extends GetxController {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final ApiService _api = ApiService.instance;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt  unreadCount = 0.obs;
  final RxBool isLoading   = false.obs;

  // ── Init ──────────────────────────────────────────────────────
  Future<void> init() async {
    if (!kIsWeb) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios     = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (_) {},
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    await fetchFromApi();
  }

  // ── GET /api/auth/notifications/ ──────────────────────────────
  Future<void> fetchFromApi() async {
    isLoading.value = true;
    try {
      final r = await _api.get(ApiConstants.notifications, requiresAuth: true);
      if (r.isSuccess) {
        final data = r.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['notifications'] ?? data['results'] ?? data['data'] ?? []) as List;
        }
        final parsed = list.asMap().entries.map((e) =>
            AppNotification.fromJson(e.value as Map<String, dynamic>,
                id: e.key.toString())).toList();
        notifications.assignAll(parsed);
        unreadCount.value = parsed.where((n) => !n.isRead).length;
      } else {
        debugPrint('Notifications API error: ${r.errorMessage}');
      }
    } catch (e) {
      debugPrint('NotificationService.fetchFromApi error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Push system notification ───────────────────────────────────
  Future<void> pushSystemNotification({
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'aidora_requests', 'Aid Requests',
      channelDescription: 'Notifications about your humanitarian aid requests',
      importance: Importance.max, priority: Priority.high,
      playSound: true, enableVibration: true,
      color: Color(0xFF2C5F4F),
    );
    const ios = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title, body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  // ── Read management ───────────────────────────────────────────
  void markAllRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    unreadCount.value = 0;
  }

  void markRead(String id) {
    final i = notifications.indexWhere((n) => n.id == id);
    if (i != -1 && !notifications[i].isRead) {
      notifications[i] = notifications[i].copyWith(isRead: true);
      if (unreadCount.value > 0) unreadCount.value--;
    }
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
  }
}
