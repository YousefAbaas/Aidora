import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/assign_task/add.dart';
import 'package:aidora/views/org/org_one/report.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orgthree extends StatefulWidget {
  const Orgthree({super.key});
  @override
  State<StatefulWidget> createState() => _Orgthree();
}

class _Orgthree extends State<Orgthree> {
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
      ApiConstants.orgPageThree,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() { _isLoading = false; _error = res.errorMessage; });
      return;
    }

    final d = res.data as Map<String, dynamic>? ?? {};
    final tasks = ((d['tasks'] as List?) ?? []).map((e) {
      return TaskModel(
        id: e['id']?.toString() ?? '',
        title: e['title']?.toString() ?? '',
        location: e['location']?.toString() ?? '',
        assignee: e['volunteer_full_name']?.toString() ?? '',
        date: e['date']?.toString() ?? '',
        status: e['status']?.toString() ?? '',
        failureReason: e['rejection_reason']?.toString(),
      );
    }).toList();

    controller.allTasks.value = tasks;
    controller.updateSeparateLists();
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Obx(() {
        if (controller.allTasks.isEmpty) {
          return const Center(
              child: Text('No tasks found', style: TextStyle(color: Colors.grey)));
        }
        return Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildStatsCard(),
              const SizedBox(height: 24),
              ...controller.completedTasks.map(_buildTaskCard),
              const SizedBox(height: 8),
              ...controller.inProgressTasks.map(_buildTaskCard),
              const SizedBox(height: 8),
              ...controller.failedTasks.map(_buildTaskCard),
              const SizedBox(height: 80),
            ]),
          ),
          Positioned(
            bottom: 20, right: 20,
            child: Container(
              height: 65, width: 65,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(50)),
              child: IconButton(
                onPressed: () => Get.to(() => Add()),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _statItem('COMPLETED', controller.completedTasks.length, Colors.green),
        _statItem('IN PROGRESS', controller.inProgressTasks.length, Colors.blue),
        _statItem('FAILED', controller.failedTasks.length, Colors.red),
      ])),
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Column(children: [
      Text(count.toString(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
          color: Colors.grey)),
    ]);
  }

  Widget _buildTaskCard(TaskModel task) {
    final bool isFailed = task.status == 'failed';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_getIconForStatus(task.status), size: 20,
                color: _getColorForStatus(task.status)),
            const SizedBox(width: 8),
            Expanded(child: Text(task.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getColorForStatus(task.status)?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(task.status.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: _getColorForStatus(task.status))),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(task.location,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(task.assignee,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
            Text(task.date,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ]),
          if (isFailed && task.failureReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text('"${task.failureReason}"',
                    style: TextStyle(fontSize: 13, color: Colors.red.shade700,
                        fontStyle: FontStyle.italic))),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (task.status == 'completed')
              Expanded(child: MaterialButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () => Get.to(
                    () => Report(), arguments: int.tryParse(task.id) ?? 0),
                child: const Text('View Report',
                    style: TextStyle(color: Colors.white)),
              )),
            if (task.status == 'failed')
              MaterialButton(
                color: const Color.fromARGB(255, 192, 191, 191),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () async {
                  final res = await ApiService.instance.patch(
                    '${ApiConstants.orgPageThree}${task.id}/reassign/',
                    body: {}, requiresAuth: true,
                  );
                  if (!res.isSuccess) {
                    Get.snackbar(
                      "Failed to reassign",
                      res.errorMessage ?? "Please try again.",
                      colorText: Colors.red,
                    );
                    return;
                  }
                  _init();
                },
                child: const Text('    Reassign Task    ',
                    style: TextStyle(color: Colors.black)),
              ),
          ]),
        ]),
      ),
    );
  }

  IconData? _getIconForStatus(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle_outline;
      case 'pending':   return Icons.pending_outlined;
      case 'failed':    return Icons.cancel_outlined;
    }
    return null;
  }

  Color? _getColorForStatus(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending':   return Colors.blue;
      case 'failed':    return Colors.red;
    }
    return null;
  }
}
