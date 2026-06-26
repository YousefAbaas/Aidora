import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color _primary = Color(0xFF2C5F4F);
  static const Color _bg      = Color(0xFFF5F3ED);

  @override
  Widget build(BuildContext context) {
    final svc = NotificationService.to;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              color: _bg,
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Color(0xFF2C3E3C), size: 20),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2E28))),
                  ),
                  Obx(() {
                    if (svc.unreadCount.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: svc.markAllRead,
                      child: Text('Mark all read',
                          style: TextStyle(
                              fontSize: 13,
                              color: _primary,
                              fontWeight: FontWeight.w600)),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.delete_sweep_rounded,
                        color: Colors.grey[500], size: 22),
                    tooltip: 'Clear all',
                    onPressed: () => _confirmClear(context, svc),
                  ),
                ],
              ),
            ),

            // ── Unread count banner ──────────────────────────────
            Obx(() {
              if (svc.unreadCount.value == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: _primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Obx(() => Text(
                          '${svc.unreadCount.value} unread notification'
                          '${svc.unreadCount.value == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: _primary,
                              fontWeight: FontWeight.w600))),
                  ],
                ),
              );
            }),

            // ── Notification list ────────────────────────────────
            Expanded(
              child: Obx(() {
                if (svc.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _primary),
                  );
                }
                if (svc.notifications.isEmpty) {
                  return _emptyState();
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
        cacheExtent: 500,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: svc.notifications.length,
                  itemBuilder: (_, i) => _NotifCard(
                    notif: svc.notifications[i],
                    svc: svc,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded,
                  size: 54, color: _primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            const Text('All caught up!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E28))),
            const SizedBox(height: 8),
            Text('No notifications yet.',
                style:
                    TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );

  void _confirmClear(
      BuildContext context, NotificationService svc) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: Text('Clear all notifications?'),
      content: Text(
          'This will remove all notifications from the list.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,)),
        ElevatedButton(
          onPressed: () {
            svc.clearAll();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400]),
          child: Text('Clear all',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

// ── Notification Card ──────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final NotificationService svc;

  const _NotifCard({required this.notif, required this.svc});

  // Color per notification_type
  Color get _color {
    switch (notif.type) {
      case NotifType.approved: return const Color(0xFF27AE60);
      case NotifType.assigned: return const Color(0xFF2980B9);
      case NotifType.rejected: return const Color(0xFFE74C3C);
    }
  }

  IconData get _icon {
    switch (notif.type) {
      case NotifType.approved: return Icons.check_circle_rounded;
      case NotifType.assigned: return Icons.inventory_2_rounded;
      case NotifType.rejected: return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => svc.markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.white
              : const Color(0xFFF0FAF5),
          borderRadius: BorderRadius.circular(16),
          border: Border(
              left: BorderSide(color: _color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(notif.isRead ? 0.03 : 0.06),
              blurRadius: notif.isRead ? 6 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type icon bubble ─────────────────────────────
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),

              const SizedBox(width: 12),

              // ── Content ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + unread dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: const Color(0xFF1A2E28),
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C5F4F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Message — direct from API "message" field
                    Text(
                      notif.message,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5),
                    ),

                    const SizedBox(height: 8),

                    // Timestamp — direct from API "created_at" field
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          notif.createdAt,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
