import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_navigation_bar.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Assignnewtask extends StatefulWidget {
  const Assignnewtask({super.key});
  @override
  State<StatefulWidget> createState() => _Assignnewtask();
}

class _Assignnewtask extends State<StatefulWidget> {
  int id = Get.arguments;
  bool _isLoading = true;
  String? _loadError;

  @override
  void dispose() {
    super.dispose();
    controller.taskTitle.clear();
    controller.description.clear();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _loadError = null; });

    final res = await ApiService.instance.get(
      "${ApiConstants.orgAssignTask}$id/",
      requiresAuth: true,
    );

    if (!mounted) return;

    if (!res.isSuccess) {
      setState(() { _isLoading = false; _loadError = res.errorMessage; });
      return;
    }

    final data = res.data;
    controller.requestId.value = data['id'];
    controller.logo.value = data['service_icon']?.toString() ?? "";
    controller.assistanceType.value =
        data['service_name']?.toString() ?? "";
    controller.locations.value = data['sector']?.toString() ?? "";
    controller.volunt.clear();
    final volunteerList = (data is Map && data['volunteers'] is List)
        ? data['volunteers'] as List
        : <dynamic>[];
    controller.volunt.assignAll(
      volunteerList.map((e) {
        return {"id": e['id'] ?? '', "fullname": e['full_name'] ?? ''};
      }).toList(),
    );

    setState(() { _isLoading = false; });
  }

  // حقن المتحكم
  FormController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assign New Task')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_loadError!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: const Text('Retry')),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Assign New Task'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم: REQUEST معلومات
            _buildRequestSection(),
            const SizedBox(height: 24),
            _buildRequestVolunteer(),
            // قسم: Task details
            _buildTaskDetailsSection(),
            const SizedBox(height: 32),
            // أزرار: Create and Assign + Cancel
            _buildActionButtons(),
          ],
        ),
      ),

      // مؤشر تحميل يظهر فوق المحتوى عند الضغط على إنشاء
    );
  }

  // ========== قسم معلومات الطلب ==========
  Widget _buildRequestSection() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REQUEST: R-${controller.requestId.value}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  controller.iconsMap[controller.logo.value]?.icon,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.assistanceType.value,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.locations.value,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestVolunteer() {
    return Obx(
      () => DropdownButton<String>(
        isExpanded: true,
        itemHeight: null,
        hint: Text("Select User"),
        value: controller.valID.value.isEmpty ? null : controller.valID.value,

        items: controller.volunt.map((e) {
          return DropdownMenuItem<String>(
            value: e["id"].toString(),

            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),

              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e["fullname"].toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "R-${e["id"].toString()}",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          controller.valID.value = value!;
        },
      ),
    );
  }

  // ========== قسم تفاصيل المهمة ==========
  Widget _buildTaskDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Task details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 4),
          _section(
            title: "Task Title",
            child: _textField(
              controller: controller.taskTitle,
              hint: "Delivery of food basket to ${controller.requestId.value}",
              icon: Icons.task,
            ),
          ),
          SizedBox(height: 8),
          _section(
            title: "DESCRIPTION/INSTRUCTION",
            child: _textField(
              controller: controller.description,
              hint: "description",
              icon: Icons.description,
            ),
          ),
        ],
      ),
    );
  }

  // ========== أزرار الإجراء ==========
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (controller.valID.value.isEmpty) {
                Get.snackbar("Missing selection", "Please select a volunteer.",
                    colorText: Colors.red);
                return;
              }
              if (controller.taskTitle.text.trim().isEmpty) {
                Get.snackbar("Missing title", "Please enter a task title.",
                    colorText: Colors.red);
                return;
              }

              controller.isLoading.value = true;
              final res = await ApiService.instance.post(
                "${ApiConstants.orgAssignTask}$id/",
                requiresAuth: true,
                body: {
                  "volunteer_id": int.parse(controller.valID.value),
                  "title": controller.taskTitle.text,
                  "instructions": controller.description.text,
                },
              );
              controller.isLoading.value = false;

              if (!mounted) return;

              if (!res.isSuccess) {
                Get.snackbar(
                  "Failed to create task",
                  res.errorMessage ?? "Please try again.",
                  colorText: Colors.red,
                );
                return;
              }

              Get.snackbar(
                "Task Created",
                "Task created and assigned successfully.",
                colorText: Colors.green,
              );
              Get.offAll(() => Orgnavigationbar());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? CircularProgressIndicator()
                : Text(
                    'Create and Assign Task',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // 🔹 Section (Reusable)
  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // 🔹 TextField
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xffF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff7AD081)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
