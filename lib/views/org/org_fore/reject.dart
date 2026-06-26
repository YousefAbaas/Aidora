import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RejectApplicationPage extends StatelessWidget {
  RejectApplicationPage({super.key, required this.index});

  final int index;
  // تهيئة الـ Controller
  final FormController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Reject Application'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildApplicantCard(),
              const SizedBox(height: 24),
              _question('Are you sure you want to reject this application?'),
              const SizedBox(height: 15),
              _buildConfirmationQuestion(
                "This action will notify the applicant\nthat their application has not aeen\nsuccessful at this time. ",
              ),
              const SizedBox(height: 30),
              _buildActionButtons(),
              const Spacer(),
              _buildFooterNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ قسم معلومات المتقدم ------------------
  Widget _buildApplicantCard() {
    return Obx(() {
      final v = controller.listallpagefore[index];
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, child: Icon(Icons.add)),
            const SizedBox(height: 6),

            Text(
              v.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "VOLUNTEER APPLICANT",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ------------------ قسم السؤال ------------------
  Widget _question(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,

          height: 1.3,
        ),
      ),
    );
  }

  // ------------------ قسم النص ------------------
  Widget _buildConfirmationQuestion(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
          height: 1.3,
        ),
      ),
    );
  }

  // ------------------ قسم الأزرار ------------------
  Widget _buildActionButtons() {
    var w = controller.listallpagefore[index];

    return Obx(
      () => Column(
        children: [
          // زر تأكيد الرفض
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            width: double.infinity,
            height: 50,
            child: MaterialButton(
              onPressed: () async {
                controller.isLoading.value = true;

                final res = await ApiService.instance.patch(
                  "${ApiConstants.orgPageFore}${w.idNumber}/update-status/",
                  requiresAuth: true,
                  body: {"status": "rejected"},
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

                controller.setStateVolunteer(index, "rejected");
                Get.back();
              },
              child: controller.isLoading.value
                  ? CircularProgressIndicator()
                  : Text(
                      "Confirm Rejection",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // زر الإلغاء
        ],
      ),
    );
  }

  // ------------------ قسم الملاحظة السفلية ------------------
  Widget _buildFooterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Rejections are final and recorded in the system.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
