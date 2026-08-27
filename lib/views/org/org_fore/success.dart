import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessAcceptancePage extends StatelessWidget {
  SuccessAcceptancePage({super.key, required this.index});

  final int index;
  // Ø­Ù‚Ù† Ø§Ù„Ù€ Controller ØªÙ„Ù‚Ø§Ø¦ÙŠÙ‹Ø§ Ø¹Ø¨Ø± Get.put Ø£Ùˆ lazyPut
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
              // Ù‚Ø³Ù… Ø§Ù„Ù†Ø¬Ø§Ø­ (Ø£ÙŠÙ‚ÙˆÙ†Ø© + Ø¹Ù†ÙˆØ§Ù†)
              _buildSuccessHeader(),
              const SizedBox(height: 24),
              // Ù‚Ø³Ù… Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ø§Ù„ÙˆØµÙÙŠØ©
              _buildDescriptionMessage(),
              const SizedBox(height: 40),
              // Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ù…ØªØ·ÙˆØ¹ Ø§Ù„Ù…Ù‚Ø¨ÙˆÙ„
              _buildVolunteerCard(),
              const Spacer(flex: 3),
              // Ø²Ø± Ø§Ù„Ø°Ù‡Ø§Ø¨ Ø¥Ù„Ù‰ Ù„ÙˆØ­Ø© Ø§Ù„ØªØ­ÙƒÙ…
              _buildDashboardButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // (1) Ø±Ø£Ø³ Ø§Ù„Ù†Ø¬Ø§Ø­ Ù…Ø¹ Ø§Ù„Ø£ÙŠÙ‚ÙˆÙ†Ø© ÙˆØ§Ù„Ø¹Ù†ÙˆØ§Ù†
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

  // (2) Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ø§Ù„ØªÙˆØ¶ÙŠØ­ÙŠØ©
  Widget _buildDescriptionMessage() {
    return Text(
      'The volunteer has been successfully accepted and notified. '
      'They will receive an onboarding email shortly.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
    );
  }

  // (3) Ø¨Ø·Ø§Ù‚Ø© Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ù…ØªØ·ÙˆØ¹ Ø§Ù„Ù…Ù‚Ø¨ÙˆÙ„
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
            // Ø§Ù„ØµÙˆØ±Ø© Ø§Ù„Ø±Ù…Ø²ÙŠØ©
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                // Ø§Ø®ØªØµØ§Ø± Ù„Ù„Ø§Ø³Ù…
                v.name.split(' ').map((e) => e[0].toUpperCase()).join(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 2),
            // Ø§Ù„Ø§Ø³Ù…
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
                // Ø§Ù„ØªØ®ØµØµ
                Text(
                  v.helpProvided[0],
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ø´Ø§Ø±Ø© Ø§Ù„Ø­Ø§Ù„Ø© "ACCEPTED"
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

  // (4) Ø²Ø± Ø§Ù„ØªÙ†Ù‚Ù„ Ø¥Ù„Ù‰ Ù„ÙˆØ­Ø© Ø§Ù„ØªØ­ÙƒÙ…
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
