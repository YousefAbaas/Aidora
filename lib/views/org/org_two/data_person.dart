import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/assign_task/assign_new_task.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dataperson extends StatefulWidget {
  const Dataperson({super.key});

  @override
  State<StatefulWidget> createState() => _Dataperson();
}

class _Dataperson extends State<StatefulWidget> {
  int id = Get.arguments;
  bool _isLoading = true;
  String? _loadError;

  // حقن المتحكم
  final FormController controller = Get.find();
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _loadError = null; });

    final res = await ApiService.instance.get(
      "${ApiConstants.orgPageTwo}${id}",
      requiresAuth: true,
    );

    if (!mounted) return;

    if (!res.isSuccess) {
      setState(() { _isLoading = false; _loadError = res.errorMessage; });
      return;
    }

    setState(() {
      controller.personOne.orgname = res.data['organization_name'] ?? '';
      controller.personOne.orglogo = '';
      controller.personOne.fullName = res.data['refugee_name'] ?? '';
      controller.personOne.id = res.data['request_id'] ?? id;
      controller.personOne.task = res.data['service_name'] ?? '';
      controller.personOne.taskIcon = res.data['service_icon'] ?? '';
      controller.personOne.locationPersonProfile = res.data['location'] ?? '';
      controller.personOne.phoneNumber = res.data['phone_number'] ?? '';
      controller.personOne.totalMembers = res.data['family_members_count'] ?? 0;
      controller.personOne.urgencyLevel = res.data['urgency_level'] ?? '';
      controller.personOne.description = res.data['description'] ?? '';
      controller.personOne.status = res.data['status'] ?? '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 3),
                Text(
                  controller.personOne.orgname,
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
            Icon(Icons.notifications_none),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Name & Case ID
            _buildHeader(controller),

            const SizedBox(height: 16),

            // 2. Food Assistance Tag
            _buildFoodAssistanceTag(),

            const SizedBox(height: 16),

            // 3. Location Card
            _buildLocationCard(controller),

            const SizedBox(height: 16),

            // 4. Personal Information Card
            _buildPersonalInfoCard(controller),

            const SizedBox(height: 16),

            // 5. Family Details Card
            _buildFamilyDetailsCard(controller),

            const SizedBox(height: 16),

            // 6. Description Card
            _buildDescriptionCard(controller),

            const SizedBox(height: 24),

            // 7. Action Buttons
            _buildActionButtons(controller),
          ],
        ),
      ),
    );
  }

  // ========== Widgets مُقسمة ==========

  Widget _buildHeader(FormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.personOne.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                controller.personOne.status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ],
        ),
        Text(
          "Case ID: ${controller.personOne.id} ",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodAssistanceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.iconsMap[controller.personOne.taskIcon]?.icon,
            color: controller.iconsMap[controller.personOne.taskIcon]?.color,
          ),
          const SizedBox(width: 8),
          Text(
            controller.personOne.task,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(FormController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade400, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Current Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.personOne.locationPersonProfile,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(FormController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Full Name', controller.personOne.fullName),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Phone Number',
              controller.personOne.phoneNumber,
              icon: Icons.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyDetailsCard(FormController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Total Members',
                    controller.personOne.totalMembers.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailTile(
                    'Urgency Level',
                    controller.personOne.urgencyLevel,
                    Icons.priority_high,
                    controller.personOne.urgencyLevel.toLowerCase() == 'normal'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(03),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(FormController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.personOne.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(FormController controller) {
    if (controller.personOne.status == "pending") {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.bottomSheet(
                      barrierColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Container(
                          height: 500,
                          color: const Color.fromARGB(255, 197, 197, 197),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 182, 252, 149),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.check_circle_outline_outlined,
                                        size: 70,
                                        color: const Color.fromARGB(
                                          255,
                                          26,
                                          139,
                                          30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Request Approved Successfully",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "${controller.personOne.fullName}'s request status has\n been updated to 'Approved'. You can\n now start assigning a volunteer for this \ntask",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 30),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Obx(
                                      () => TextButton(
                                        onPressed: () async {
                                          controller.isLoading.value = true;
                                          final res = await ApiService.instance.post(
                                            "${ApiConstants.orgPageTwoApproved}${id}/approve/",
                                            body: {},
                                            requiresAuth: true,
                                          );

                                          controller.isLoading.value = false;

                                          if (!res.isSuccess) {
                                            Get.snackbar(
                                              "Failed to approve",
                                              res.errorMessage ?? "Please try again.",
                                              colorText: Colors.red,
                                            );
                                            return;
                                          }

                                          Get.to(
                                            () => Assignnewtask(),
                                            arguments: id,
                                          );
                                        },
                                        child: controller.isLoading.value
                                            ? CircularProgressIndicator()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.person_add_alt,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Assign Volunteer Now",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      elevation: 0,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadiusGeometry.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.bottomSheet(
                      barrierColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Container(
                          height: 500,
                          color: const Color.fromARGB(255, 197, 197, 197),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 241, 133, 133),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.do_not_disturb_on_sharp,
                                        size: 70,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Reject Request?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Please provide a reason for rejecting this \n humanitarian aid request. This Will be shared\nwith the requester.",
                                  ),
                                  SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'REJECTION REASON (REQUIREQ)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        maxLines: 3,
                                        onChanged: (value) {
                                          controller.updateResonPersonOne(
                                            value,
                                          );
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              "e.g., Missing documentation, incorrect\ndelivery coordinates, or items currently out\nof stock",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 30),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Obx(
                                      () => TextButton(
                                        onPressed: () async {
                                          controller.isLoading.value = true;
                                          final res = await ApiService.instance.post(
                                            "${ApiConstants.orgPageTwoRejected}${id}/reject/",
                                            body: {
                                              "rejection_reason": controller
                                                  .resonPersonOne
                                                  .value,
                                            },
                                            requiresAuth: true,
                                          );
                                          controller.isLoading.value = false;

                                          if (!res.isSuccess) {
                                            Get.snackbar(
                                              "Failed to reject",
                                              res.errorMessage ?? "Please try again.",
                                              colorText: Colors.red,
                                            );
                                            return;
                                          }

                                          Get.snackbar(
                                            "Request Rejected",
                                            "The request has been rejected.",
                                            colorText: Colors.green,
                                          );
                                          Get.back();
                                        },
                                        child: controller.isLoading.value
                                            ? CircularProgressIndicator()
                                            : Text(
                                                "Confirm Rejection",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        194,
                                        194,
                                        194,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      elevation: 0,
                    );
                  },
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "Assign to volunteer",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
