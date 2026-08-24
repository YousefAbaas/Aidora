import 'package:aidora/views/volunteer/form/page_one.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/volunteer/my_request/page_request.dart';

class Pagefive extends StatefulWidget {
  const Pagefive({super.key});
  @override
  State<StatefulWidget> createState() => _Pagefive();
}

class _Pagefive extends State<Pagefive> {
  final FormController controller = Get.find();

  List categoriesTrue = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xffF4F4F4),
        body: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: _formCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: Color(0xff7AD081),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 90),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "Almost there!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 50),
          Text(
            "Help us understand your impact",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 5),
          Text(
            "Step 5 of 5: Identity & Residence",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= FORM =================
  Widget _formCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //PhoneNumberEmergency
          _section(
            title: "Emergency Contact",
            child: _textField_1(
              controller: controller.phoneNumberEmergency,
              hint: "+1(555) 000-0000",
              icon: Icons.perm_phone_msg_rounded,
              texthint: Text(
                "phone Number",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          // ðŸ”¹ Volunteer
          _section(
            title: "Why do you want to volunteer?",
            child: _textField_2(
              controller: controller.volunteer,
              hint: "",
              texthint: Text(
                "Share your motivation and goais with us.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 10),
          _buildAgreementsSection(controller),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Color(0xff7AD081),
              borderRadius: BorderRadius.circular(30),
            ),
            child: MaterialButton(
              onPressed: () async {
                controller.isLoading.value = true;
                final submitRes = await ApiService.instance.post(
                  '${ApiConstants.volunteerPageFive}${controller.idOrganization}/volunteer/applications/',
                  requiresAuth: true,
                  body: {
                    "phone_number": controller.phoneNumberEmergency.text,
                    "why_volunteer": controller.volunteer.text,
                    "i_commit": controller.isPolicyCommitted.value,
                    "i_agree_terms": controller.isInfoAgreed.value,
                    "selected_services": categoriesTrue,
                  },
                );

                if (!submitRes.isSuccess) {
                  controller.isLoading.value = false;
                  Get.snackbar(
                    "Submission failed",
                    submitRes.errorMessage ?? "Please try again.",
                    colorText: Colors.red,
                  );
                  return;
                }

                final res = await ApiService.instance.get(
                  ApiConstants.volunteerStateRequest,
                  requiresAuth: true,
                );
                controller.isLoading.value = false;

                if (!res.isSuccess) {
                  Get.snackbar(
                    "Could not verify status",
                    res.errorMessage ?? "Please try again.",
                    colorText: Colors.red,
                  );
                  return;
                }

                if (res.data['profile_completed'] == false &&
                    res.data['application_status'] == null) {
                  Get.offAll(() => Pageone());
                } else {
                  Get.offAll(() => Pagerequest());
                }
              },
              child: controller.isLoading.value
                  ? CircularProgressIndicator()
                  : Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ðŸ”¹ Section (Reusable)
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

  // ðŸ”¹ TextField and icon
  Widget _textField_1({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Text texthint,
  }) {
    return Column(
      children: [
        texthint,
        Container(
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
        ),
      ],
    );
  }

  // ðŸ”¹ TextField and without icon
  Widget _textField_2({
    required TextEditingController controller,
    required String hint,
    required Text texthint,
  }) {
    return Column(
      children: [
        texthint,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xffF7F7F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
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
        ),
      ],
    );
  }

  // Ù‚Ø³Ù… Ø§Ù„Ù…ÙˆØ§ÙÙ‚Ø§Øª
  Widget _buildAgreementsSection(FormController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Ø§Ù„Ù…ÙˆØ§ÙÙ‚Ø© Ø¹Ù„Ù‰ Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª
          Obx(
            () => CheckboxListTile(
              value: controller.isInfoAgreed.value,
              onChanged: controller.toggleInfoAgreement,
              title: const Text(
                'I agree that my information may be used for volunteer coordination purposes only.',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: Get.theme.primaryColor,
            ),
          ),

          const Divider(height: 8),

          // Ø§Ù„Ù…ÙˆØ§ÙÙ‚Ø© Ø¹Ù„Ù‰ Ø³ÙŠØ§Ø³Ø© Ø­Ù…Ø§ÙŠØ© Ø§Ù„Ø·ÙÙ„
          Obx(
            () => CheckboxListTile(
              value: controller.isPolicyCommitted.value,
              onChanged: controller.togglePolicyCommitment,
              title: const Text(
                'I commit to the Child Safeguarding Policy and will uphold its standards.',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: Get.theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
