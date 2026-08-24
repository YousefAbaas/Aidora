import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_fore/volunteer_detail.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orgfore extends StatefulWidget {
  const Orgfore({super.key});
  @override
  State<StatefulWidget> createState() => _Orgfore();
}

class _Orgfore extends State<Orgfore> {
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await ApiService.instance.get(
      ApiConstants.orgPageFore,
      requiresAuth: true,
    );

    if (!mounted) return;
    if (!res.isSuccess) {
      setState(() {
        _isLoading = false;
        _error = res.errorMessage;
      });
      return;
    }

    final d = res.data as Map<String, dynamic>? ?? {};
    controller.listallpagefore.value =
        ((d['applications'] as List?) ?? []).map((e) {
      return VolunteerPageFore(
        logo: List<String>.from(e['service_icon'] ?? []),
        name: e['full_name']?.toString() ?? '',
        appliedTime: e['created_at']?.toString() ?? '',
        email: e['email']?.toString() ?? '',
        phone: e['phone_number']?.toString() ?? '',
        age: int.tryParse(e['age'].toString().replaceAll(' years', '')) ?? 0,
        location: e['current_city']?.toString() ?? '',
        idNumber: e['id']?.toString() ?? '',
        nationality: e['nationality']?.toString() ?? '',
        days: e['availability_shift']?.toString() ?? '',
        availabilityDays: List<String>.from(e['available_days'] ?? []),
        date: e['created_at']?.toString() ?? '',
        startDate: e['start_date']?.toString() ?? '',
        duration: e['expected_duration']?.toString() ?? '',
        languages: List<String>.from(e['languages'] ?? []),
        experience: e['previous_experience']?.toString() ?? '',
        education: e['education_level']?.toString() ?? '',
        helpProvided: List<String>.from(e['service_name'] ?? []),
        emergencyContact: e['Emergency']?.toString() ?? '',
        reason: e['why_volunteer']?.toString() ?? '',
        state: e['status']?.toString() ?? '',
      );
    }).toList();

    if (mounted)
      setState(() {
        _isLoading = false;
      });
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
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
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
          backgroundColor: const Color.fromARGB(240, 247, 242, 232),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(240, 247, 242, 232),
            title: const Text('Volunteer requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            bottom: TabBar(
              isScrollable: true,
              indicator: ShapeDecoration(
                color: const Color.fromARGB(255, 148, 245, 139),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              tabs: const [
                Tab(text: '       All       '),
                Tab(text: '   Approved   '),
                Tab(text: '   Pending   '),
                Tab(text: '   Rejected   '),
              ],
            ),
          ),
          body: TabBarView(children: [
            _buildTaskList(''),
            _buildTaskList('approved'),
            _buildTaskList('pending'),
            _buildTaskList('rejected'),
          ]),
        ),
      ),
    );
  }

  Widget _buildTaskList(String s) {
    return Obx(() {
      final items = s.isEmpty
          ? controller.listallpagefore.toList()
          : controller.listallpagefore.where((t) => t.state == s).toList();
      if (items.isEmpty) {
        return const Center(
            child: Text('No volunteers found',
                style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => _taskItem(items[index], index),
      );
    });
  }

  Widget _taskItem(VolunteerPageFore task, int index) {
    final iconKey = task.logo.isNotEmpty ? task.logo[0] : '';
    final firstHelp = task.helpProvided.isNotEmpty ? task.helpProvided[0] : '';
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(
              leading: CircleAvatar(
                  child: Icon(
                controller.iconsMap[iconKey]?.icon,
                color: controller.iconsMap[iconKey]?.color,
              )),
              title: Text(task.name, style: const TextStyle(fontSize: 20)),
              subtitle: Text(firstHelp),
              trailing: Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: task.state == 'approved'
                      ? Colors.green
                      : task.state == 'pending'
                          ? Colors.orange
                          : Colors.red,
                ),
                child: Center(
                    child: Text(task.state,
                        style: const TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Icon(Icons.location_on_outlined, color: Colors.blue[100]),
              const SizedBox(width: 10),
              Text(task.location),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.date_range_rounded, color: Colors.blue[100]),
              const SizedBox(width: 10),
              Text(task.date),
            ]),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // Pass the correct index from the full list for VolunteerDetailScreen
                  final fullIndex = controller.listallpagefore.indexOf(task);
                  Get.to(() => VolunteerDetailScreen(index: fullIndex));
                },
                child: Container(
                  height: 50,
                  width: 150,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('View Details',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Icon(Icons.arrow_forward_ios),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
