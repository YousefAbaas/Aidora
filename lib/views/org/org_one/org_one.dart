import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_one/report.dart';
import 'package:aidora/views/org/org_two/data_person.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orgone extends StatefulWidget {
  const Orgone({super.key});
  @override
  State<StatefulWidget> createState() => _Orgone();
}

class _Orgone extends State<Orgone> {
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
      ApiConstants.orgPageOne,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() { _isLoading = false; _error = res.errorMessage; });
      return;
    }

    final d = res.data as Map<String, dynamic>? ?? {};
    controller.pageOne.approved.value   = (d['approved']  as num?)?.toInt() ?? 0;
    controller.pageOne.inProgress.value = (d['pending']   as num?)?.toInt() ?? 0;
    controller.pageOne.completed.value  = (d['completed'] as num?)?.toInt() ?? 0;
    controller.pageOne.requests.assignAll(
      ((d['requests'] as List?) ?? []).map((e) => Map<String, Object>.from(e as Map)),
    );
    controller.pageOne.tasks.assignAll(
      ((d['tasks'] as List?) ?? []).map((e) => Map<String, Object>.from(e as Map)),
    );
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
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: const Text('Retry')),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _init,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Column(children: [
                _buildStatCard(
                  title: 'New request',
                  value: controller.pageOne.approved.value,
                  color1: const Color(0xffffedd5),
                  color2: const Color(0xffea580c),
                  icon: Icons.note_add_outlined,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'In progress',
                  value: controller.pageOne.inProgress.value,
                  color1: const Color(0x440a94c2),
                  color2: const Color(0xff0a94c2),
                  icon: Icons.hourglass_bottom_rounded,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Completed',
                  value: controller.pageOne.completed.value,
                  color1: const Color(0xffdcfce7),
                  color2: const Color(0xff16a34a),
                  icon: Icons.check_circle_outline,
                ),
              ])),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent New Requests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => controller.orgCurrentIndex.value = 1,
                    child: const Text('View All',
                        style: TextStyle(color: Color(0xFF1CABE2))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => Column(
                children: controller.pageOne.requests.map(_buildRecentRequestCard).toList(),
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Completed Tasks',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Report Log', style: TextStyle(color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => Column(
                children: controller.pageOne.tasks.map(_buildCompletedTaskCard).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required int value,
      required Color color1, required Color color2, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color1, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color2, size: 28),
        ),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('$value',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        ]),
      ]),
    );
  }

  Widget _buildRecentRequestCard(Map<String, Object> req) {
    const typeColors = {
      'protection': Color(0xFF1565C0), 'education': Color(0xFF7E57C2),
      'water': Color(0xFF29B6F6), 'health': Color(0xFF43A047),
      'food': Color(0xFFFB8C00), 'shelter': Color(0xFF8D6E63),
      'logistics': Color(0xFF546E7A), 'legal': Color(0xFF3949AB),
      'emergency': Color(0xFFE53935), 'vaccination': Color(0xFF26A69A),
    };
    final typeColor = typeColors[req['service_type']] ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ID: ${req['id'] ?? 'Null'}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(req['service_type']?.toString() ?? '',
                style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(child: Text(req['location']?.toString() ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 13))),
          ])),
          IconButton(
            onPressed: () => Get.to(() => Dataperson(), arguments: req['id']),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ]),
        Text('Received on ${req['created_at'] ?? ''}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
    );
  }

  Widget _buildCompletedTaskCard(Map<String, Object> task) {
    final bool state = (task['report_reviewed'] as bool?) ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: Color(0xffdcfce7), shape: BoxShape.circle),
            child: state
                ? const Icon(Icons.check, color: Colors.green, size: 16)
                : const Icon(Icons.task, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task['title']?.toString() ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text('Vol: ${task['full_name'] ?? ''} . ${task['current_city'] ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            Text('${task['time_since_completed'] ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ])),
        ])),
        Column(children: [
          Text('id :  ${task['id']}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          state
              ? const Icon(Icons.remove_red_eye)
              : TextButton(
                  onPressed: () {
                    Get.to(() => Report(), arguments: task['id']);
                    setState(() {});
                  },
                  child: const Text('REPORT')),
        ]),
      ]),
    );
  }
}
