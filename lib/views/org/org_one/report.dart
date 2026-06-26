import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_navigation_bar.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Report extends StatefulWidget {
  const Report({super.key});
  @override
  State<StatefulWidget> createState() => _Report();
}

class _Report extends State<StatefulWidget> {
  int id = Get.arguments;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _loadError = null; });

    final res = await ApiService.instance.get(
      "${ApiConstants.orgReport}${id}/report/",
      requiresAuth: true,
    );

    if (!mounted) return;

    if (!res.isSuccess) {
      setState(() { _isLoading = false; _loadError = res.errorMessage; });
      return;
    }

    setState(() {
      controller.reportID.value = Map<String, Object>.from(res.data ?? {});
      _isLoading = false;
    });
  }

  // حقن المتحكم
  final FormController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Report',
            style: TextStyle(color: Colors.blue, fontSize: 30),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(15),
              ),
              elevation: 5,
              child: Column(
                children: [
                  SizedBox(height: 8),
                  // شارة "Completed"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.reportID.value['title'].toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24, thickness: 1),
                        // التاريخ والوقت
                        _buildInfoRow(
                          icon: Icons.date_range,
                          color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date & Time"),
                              SizedBox(height: 2),
                              Text(
                                controller.reportID.value['created_at']
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // الموقع
                        _buildInfoRow(
                          icon: Icons.location_on,
                          color: Colors.blue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location"),
                              SizedBox(height: 2),
                              Text(
                                controller.reportID.value['location']
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // المتطوع وزر الإكمال
                        _buildInfoRow(
                          icon: Icons.handshake,
                          color: Colors.red,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Volunteer"),
                              SizedBox(height: 2),
                              Text(
                                controller.reportID.value['full_name']
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text("Complete this task"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "Task Description",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // وصف المهمة
                        Text(
                          controller.reportID.value['instructions'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // قسم نقاط الأداء
            const Text(
              "Award Performance Points",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                Obx(() {
                  return Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: Text(
                        "+${controller.selectedPoints.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPointButton(5),
                    _buildPointButton(10),
                    _buildPointButton(20),
                  ],
                ),
                SizedBox(height: 5),
                IconButton(
                  onPressed: () {
                    Get.bottomSheet(
                      barrierColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),

                        child: Container(
                          color: const Color.fromARGB(255, 197, 197, 197),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Edit Performance Points",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(
                                        () => Text(
                                          "${controller.selectedPoints.value}",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text("pts"),
                                      SizedBox(height: 50),
                                    ],
                                  ),
                                  Obx(
                                    () => Slider(
                                      min: 0,
                                      max: 10000,
                                      divisions: 100,
                                      value: controller.selectedPoints.value
                                          .toDouble(),
                                      label: controller.selectedPoints.value
                                          .toString(),
                                      onChanged: (double newValue) {
                                        controller.updateValue(
                                          newValue.round(),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _bottomSheet(5),
                                      SizedBox(width: 5),
                                      _bottomSheet(10),
                                      SizedBox(width: 5),
                                      _bottomSheet(25),
                                      SizedBox(width: 5),
                                      _bottomSheet(50),
                                    ],
                                  ),
                                  SizedBox(height: 40),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        controller.isLoading.value = true;
                                        final res = await ApiService.instance.patch(
                                          "${ApiConstants.orgReport}${id}/report/",
                                          requiresAuth: true,
                                          body: {
                                            "points":
                                                controller.selectedPoints.value,
                                          },
                                        );
                                        controller.isLoading.value = false;

                                        if (!res.isSuccess) {
                                          Get.snackbar(
                                            "Failed to update points",
                                            res.errorMessage ?? "Please try again.",
                                            colorText: Colors.red,
                                          );
                                          return;
                                        }

                                        Get.offAll(() => Orgnavigationbar());
                                      },
                                      child: controller.isLoading.value
                                          ? CircularProgressIndicator()
                                          : Text(
                                              "Update Points",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
            // عرض النقاط المختارة
          ],
        ),
      ),
    );
  }

  /// ويدجيت الازرار
  Widget _bottomSheet(int text) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextButton(
          onPressed: () {
            controller.selectPoints(text);
          },
          child: Text("+$text"),
        ),
      ),
    );
  }

  /// ويدجت مساعد لصفوف المعلومات
  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  /// زر اختيار النقاط
  Widget _buildPointButton(int points) {
    return FloatingActionButton(
      onPressed: () {
        controller.selectPoints(points);
      },
      child: Text("+$points"),
    );
  }
}
