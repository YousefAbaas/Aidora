import 'package:aidora/controllers/Controller_Two.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class Updatestatustwo extends StatelessWidget {
  Updatestatustwo({super.key, required this.index});

  final int index;

  // Ø§Ø³ØªØ¯Ø¹Ø§Ø¡ Ø§Ù„Ù€ Controller Ø¨Ø§Ø³ØªØ®Ø¯Ø§Ù… GetX
  final FormController controller = Get.find();
  final ControllerTwo controllerTwo = Get.put(ControllerTwo());

  late Map<String, Object> item;

  @override
  Widget build(BuildContext context) {
    item = controller.taskInTask[index];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Update Status'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ø±Ù‚Ù… Ø§Ù„Ø·Ù„Ø¨ ÙˆÙ…Ù†ØµØ¨ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…
                  Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            Icons.volunteer_activism,
                            color: Color(0xff7AD081),
                          ),
                        ),
                        title: Text(item['title'].toString()),
                        subtitle: Text("Request"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Ø¹Ù†ÙˆØ§Ù† "Select New Status"
                  const Text(
                    'Select New Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Ø®ÙŠØ§Ø± Mark as Completed
                  Obx(
                    () => RadioListTile<String>(
                      title: const Text(
                        'Mark as Completed',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Successfully finished the task',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      value: 'completed',
                      // ignore: deprecated_member_use
                      groupValue: controllerTwo.selectedStatus.value,
                      // ignore: deprecated_member_use
                      onChanged: (value) => {
                        controllerTwo.changeStatus(value!),
                      },
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      tileColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Ø®ÙŠØ§Ø± Mark as Failed
                  Obx(
                    () => RadioListTile<String>(
                      title: const Text(
                        'Mark as Failed',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Unable to fulfill this request',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      value: 'failed',
                      // ignore: deprecated_member_use
                      groupValue: controllerTwo.selectedStatus.value,
                      // ignore: deprecated_member_use
                      onChanged: (value) => {
                        controllerTwo.changeStatus(value!),
                      },
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                      tileColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ø­Ù‚Ù„ Ø³Ø¨Ø¨ Ø§Ù„ÙØ´Ù„ (ÙŠØ¸Ù‡Ø± ÙÙ‚Ø· Ø¹Ù†Ø¯ Ø§Ø®ØªÙŠØ§Ø± Failed)
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: controllerTwo.selectedStatus.value == 'failed'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reason for Failed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLines: 3,
                                  onChanged: controllerTwo.updateFailureReason,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Please describe why this request cannot be fulfilled...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ù…Ù„Ø§Ø­Ø¸Ø© (Note)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: This message will be shared with the request coordinator.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ø²Ø± Confirm Update
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await ApiService.instance.patch(
                          "${ApiConstants.volunteerTasks}${controller.taskInTask[index]['id']}/update/",
                          requiresAuth: true,
                          body: {
                            "status": controllerTwo.selectedStatus.value,
                            "rejection_reason":
                                controllerTwo.failureReason.value,
                          },
                        );

                        if (!res.isSuccess) {
                          Get.snackbar(
                            "Failed to update status",
                            res.errorMessage ?? "Please try again.",
                            colorText: Colors.red,
                          );
                          return;
                        }

                        if (controllerTwo.selectedStatus.value == "completed") {
                          controller.completed.value++;
                          controller.pending.value--;
                        } else if (controllerTwo.selectedStatus.value ==
                            "failed") {
                          controller.failed.value++;
                          controller.pending.value--;
                        }
                        controller.updateData(
                          index,
                          controllerTwo.selectedStatus.value,
                          controllerTwo.failureReason.value,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff7AD081),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Confirm Update â†’',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
