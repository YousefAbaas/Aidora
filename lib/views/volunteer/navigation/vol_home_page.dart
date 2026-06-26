import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/views/notifications_screen.dart';
import 'package:aidora/widgets/vol_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/controllers/vol_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final FormController controller = Get.find();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    final res = await ApiService.instance.get(
      ApiConstants.volunteerHome,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() { _isLoading = false; _error = res.errorMessage; });
      return;
    }

    final d = res.data as Map<String, dynamic>? ?? {};

    // Update VolController reactively (shared across screens)
    final name   = d['full_name']?.toString()     ?? '';
    final rawImg = d['profile_image']?.toString() ?? '';
    if (Get.isRegistered<VolController>()) {
      if (name.isNotEmpty)   VolController.to.volName.value     = name;
      if (rawImg.isNotEmpty) VolController.to.volImageUrl.value = rawImg;
    }
    // Also keep FormController in sync for backward compat
    controller.userName.value = name;

    controller.failed.value    = (d['statistics']?['failed']    as num?)?.toInt() ?? 0;
    controller.completed.value = (d['statistics']?['completed'] as num?)?.toInt() ?? 0;
    controller.pending.value   = (d['statistics']?['pending']   as num?)?.toInt() ?? 0;
    controller.tasksthreeHome.assignAll(
      ((d['recent_tasks'] as List?) ?? []).map((e) => Map<String, Object>.from(e as Map)),
    );
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F3EF),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F3EF),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _init, child: const Text('Retry')),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _init,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const Text('Home',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildStats(),
              const SizedBox(height: 25),
              _buildNewHeader(),
              const SizedBox(height: 10),
              Expanded(child: _buildTaskList()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          // ── Reactive volunteer avatar ──────────────────────────
          const VolAvatar(size: 44, borderWidth: 2),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back,',
                style: TextStyle(color: Colors.grey)),
            Obx(() => Text(
              VolController.to.volName.value.isNotEmpty
                  ? VolController.to.volName.value
                  : controller.userName.value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            )),
          ]),
        ]),
        // ── Notification bell with badge ──────────────────────────
        Obx(() {
          final count = NotificationService.to.unreadCount.value;
          return Stack(clipBehavior: Clip.none, children: [
            IconButton(
              onPressed: () => Get.to(
                () => const NotificationsScreen(),
                transition: Transition.cupertino,
              ),
              icon: const Icon(Icons.notifications_none),
            ),
            if (count > 0)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ]);
        }),
      ],
    );
  }

  Widget _buildStats() {
    return Column(children: [
      Row(children: [
        Expanded(child: _statCard(title: 'Failed', value: controller.failed,
            color: Colors.red.shade100, textColor: Colors.red,
            icon: Icons.close)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(title: 'Pending', value: controller.pending,
            color: Colors.orange.shade100, textColor: Colors.orange,
            icon: Icons.hourglass_bottom)),
      ]),
      const SizedBox(height: 12),
      Center(child: SizedBox(width: 180,
          child: _statCard(title: 'Completed', value: controller.completed,
              color: Colors.blue.shade100, textColor: Colors.blue,
              icon: Icons.check_circle))),
    ]);
  }

  Widget _statCard({required String title, required RxInt value,
      required Color color, required Color textColor, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color,
          borderRadius: BorderRadius.circular(16)),
      child: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: textColor),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(color: textColor)),
        const SizedBox(height: 5),
        Text(value.value.toString(),
            style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold, color: textColor)),
      ])),
    );
  }

  Widget _buildNewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('New',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => controller.currentIndex.value = 1,
          child: const Text('View All',
              style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return Obx(() => ListView.builder(
      itemCount: controller.tasksthreeHome.length > 3
          ? 3
          : controller.tasksthreeHome.length,
      itemBuilder: (context, index) =>
          _taskItem(controller.tasksthreeHome[index]),
    ));
  }

  Widget _taskItem(Map task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10)),
          child: Center(child: Icon(
            controller.iconsMap[task['icon']]?.icon,
            color: controller.iconsMap[task['icon']]?.color,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(task['title']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${task["created_display"]} • ${task["location"]}',
              style: const TextStyle(color: Colors.grey)),
        ])),
      ]),
    );
  }
}
