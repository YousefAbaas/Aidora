import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_two/data_person.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orgtwo extends StatefulWidget {
  const Orgtwo({super.key});
  @override
  State<StatefulWidget> createState() => _Orgtwo();
}

class _Orgtwo extends State<Orgtwo> {
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
      ApiConstants.orgPageTwo,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() { _isLoading = false; _error = res.errorMessage; });
      return;
    }

    final list = res.data as List? ?? [];
    controller.listallpagetwo.assignAll(
      list.map<Map<String, String>>((item) {
        final e = item as Map<String, dynamic>;
        return {
          'ID':       e['id']?.toString()           ?? '',
          'title':    e['refugee_name']?.toString() ?? '',
          'id':       e['request_id']?.toString()   ?? '',
          'taskName': e['service_name']?.toString() ?? '',
          'icon':     e['icon']?.toString()         ?? '',
          'location': e['location']?.toString()     ?? '',
          'date':     e['request_date']?.toString() ?? '',
          'state':    e['status']?.toString()       ?? '',
        };
      }).toList(),
    );
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(240, 247, 242, 232),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(240, 247, 242, 232),
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
        length: 5,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(240, 247, 242, 232),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(240, 247, 242, 232),
            title: const Text('Assistance requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            bottom: TabBar(
              isScrollable: true,
              indicator: ShapeDecoration(
                color: const Color.fromARGB(255, 148, 245, 139),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              tabs: const [
                Tab(text: '     All     '),
                Tab(text: '   Completed   '),
                Tab(text: '   In review   '),
                Tab(text: '   Approve   '),
                Tab(text: '   Rejected   '),
              ],
            ),
          ),
          body: TabBarView(children: [
            _buildTaskList(''),
            _buildTaskList('completed'),
            _buildTaskList('pending'),
            _buildTaskList('approved'),
            _buildTaskList('rejected'),
          ]),
        ),
      ),
    );
  }

  Widget _buildTaskList(String s) {
    return Obx(() {
      final items = s.isEmpty
          ? controller.listallpagetwo.toList()
          : controller.listallpagetwo.where((t) => t['state'] == s).toList();
      if (items.isEmpty) {
        return const Center(child: Text('No requests found',
            style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => _taskItem(items[index], index),
      );
    });
  }

  Widget _taskItem(Map<String, String> task, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(
              title: Text(task['title'] ?? 'NULL', style: const TextStyle(fontSize: 20)),
              subtitle: Text(task['id'] ?? 'NULL'),
              trailing: Container(
                width: 70, height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: task['state'] == 'completed'
                      ? Colors.green[200]
                      : task['state'] == 'pending'
                          ? Colors.orange[200]
                          : task['state'] == 'approved'
                              ? Colors.green[200]
                              : Colors.red[200],
                ),
                child: Center(child: Text(task['state'] ?? 'NULL',
                    style: const TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Icon(controller.iconsMap[task['icon']]?.icon, color: Colors.blue[100]),
              const SizedBox(width: 10),
              Text(task['taskName'] ?? 'NULL'),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.location_on_outlined, color: Colors.blue[100]),
              const SizedBox(width: 10),
              Text(task['location'] ?? 'NULL'),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.date_range_rounded, color: Colors.blue[100]),
              const SizedBox(width: 10),
              Text(task['date'] ?? 'NULL'),
            ]),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Get.to(
                  () => Dataperson(),
                  arguments: int.tryParse(task['ID'] ?? '0') ?? 0,
                ),
                child: Container(
                  height: 50, width: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xff5ba9c7),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(child: Text('View Details',
                      style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
