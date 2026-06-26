import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessAcceptancePage extends StatelessWidget {
  SuccessAcceptancePage({super.key, required this.index});

  final int index;
  // حقن الـ Controller تلقائيًا عبر Get.put أو lazyPut
  final FormController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Acceptance",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // قسم النجاح (أيقونة + عنوان)
              _buildSuccessHeader(),
              const SizedBox(height: 24),
              // قسم الرسالة الوصفية
              _buildDescriptionMessage(),
              const SizedBox(height: 40),
              // بطاقة المتطوع المقبول
              _buildVolunteerCard(),
              const Spacer(flex: 3),
              // زر الذهاب إلى لوحة التحكم
              _buildDashboardButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // (1) رأس النجاح مع الأيقونة والعنوان
  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          height: 160,
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 100,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Success',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  // (2) الرسالة التوضيحية
  Widget _buildDescriptionMessage() {
    return Text(
      'The volunteer has been successfully accepted and notified. '
      'They will receive an onboarding email shortly.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
    );
  }

  // (3) بطاقة معلومات المتطوع المقبول
  Widget _buildVolunteerCard() {
    return Obx(() {
      var v = controller.listallpagefore[index];

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الصورة الرمزية
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                // اختصار للاسم
                v.name.split(' ').map((e) => e[0].toUpperCase()).join(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 2),
            // الاسم
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                // التخصص
                Text(
                  v.helpProvided[0],
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // شارة الحالة "ACCEPTED"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'ACCEPTED',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // (4) زر التنقل إلى لوحة التحكم
  Widget _buildDashboardButton() {
    var w = controller.listallpagefore[index];

    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            controller.isLoadingAccess.value = true;

            final res = await ApiService.instance.patch(
              "${ApiConstants.orgPageFore}${w.idNumber}/update-status/",
              requiresAuth: true,
              body: {"status": "approved"},
            );

            controller.isLoadingAccess.value = false;

            if (!res.isSuccess) {
              Get.snackbar(
                "Failed to approve",
                res.errorMessage ?? "Please try again.",
                colorText: Colors.red,
              );
              return;
            }

            controller.setStateVolunteer(index, "approved");
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0x55ec5b13),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: controller.isLoadingAccess.value
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Go to Dashboard',
                      style: TextStyle(color: Color(0xffec5b13)),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.dashboard, color: Color(0xffec5b13)),
                  ],
                ),
        ),
      ),
    );
  }
}
