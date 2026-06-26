import 'package:aidora/views/org/update_status/update_status.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Alltask extends StatefulWidget {
  const Alltask({super.key});
  @override
  State<StatefulWidget> createState() => _A();
}

class _A extends State<Alltask> {
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
      ApiConstants.volunteerTasks,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() { _isLoading = false; _error = res.errorMessage; });
      return;
    }

    final d = res.data as Map<String, dynamic>? ?? {};
    final results = (d['results'] as List?) ?? [];
    controller.taskInTask.assignAll(
      results.map<Map<String, Object>>((item) {
        final e = item as Map<String, dynamic>;
        final Map<String, Object> newMap = {};
        e.forEach((key, value) {
          if (value == null) {
            newMap[key] = '';
          } else {
            newMap[key] = value;
          }
        });
        return newMap;
      }).toList(),
    );
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
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
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('All Tasks')),
            bottom: const TabBar(tabs: [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Pending'),
              Tab(text: 'Failed'),
            ]),
          ),
          body: TabBarView(children: [
            _buildTaskList(''),
            _buildTaskList('completed'),
            _buildTaskList('pending'),
            _buildTaskList('failed'),
          ]),
        ),
      ),
    );
  }

  Widget _buildTaskList(String s) {
    return Obx(() {
      final items = s.isEmpty
          ? controller.taskInTask.toList()
          : controller.taskInTask.where((t) => t['status'] == s).toList();
      if (items.isEmpty) {
        return const Center(child: Text('No tasks found',
            style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => _taskItem(items[index], index),
      );
    });
  }

  Widget _taskItem(Map<String, Object> task, int index) {
    final status = task['status']?.toString() ?? '';
    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(status, style: TextStyle(
            color: status == 'completed'
                ? Colors.green
                : status == 'pending'
                    ? Colors.orange
                    : Colors.red,
          )),
          const SizedBox(height: 10),
          Text(task['title']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 5),
            Text(' ${task["created_at_display"]} '),
            const Icon(Icons.circle, size: 7),
            const Icon(Icons.location_on),
            Text(task['location']?.toString() ?? ''),
          ]),
          ListTile(
            subtitle: Text(
              status == 'pending' ? 'Sent ${task["time_ago"] ?? ""}' : '',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
          if (status == 'pending' || status == 'completed')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Find real index in full list
                  final realIndex = controller.taskInTask.indexOf(task);
                  Get.to(() => Updatestatus(index: realIndex >= 0 ? realIndex : index));
                },
                child: const Text('View Details'),
              ),
            ),
        ]),
      ),
    );
  }
}
