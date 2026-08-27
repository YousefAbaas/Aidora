import 'package:aidora/views/volunteer/form/page_fore.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Pagethree extends StatefulWidget {
  const Pagethree({super.key});
  @override
  State<StatefulWidget> createState() => _Pagethree();
}

class _Pagethree extends State<Pagethree> {
  final FormController controller = Get.find();

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
              SizedBox(width: 50),
              Text(
                "SKILLS & EXPERIENCE",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "Tell us about\nYour skills",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Step 3 of 5: Identity & Residence",
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
          // ðŸ”¹ Education
          _section(
            title: "Education level",
            child: _textField(
              controller: controller.education,
              hint: "Master",
              icon: Icons.school,
            ),
          ),

          // ðŸ”¹ Languages
          _section(
            title: "Languages spoken",
            child: _textField(
              controller: controller.languagesThree,
              hint: "English, Arabic",
              icon: Icons.translate,
            ),
          ),

          // ðŸ”¹ Experience
          _section(
            title: "Previous volunteering experience",
            child: _textField(
              controller: controller.experienceController,
              hint: "Briefly describe your past roles....",
              icon: Icons.volunteer_activism,
            ),
          ),

          // ðŸ”¹ Skills
          _section(
            title: "Relevant skills",
            child: _textField(
              controller: controller.skillsController,
              hint: "e.g project Mgmt, First Aid....",
              icon: Icons.auto_awesome,
            ),
          ),
          SizedBox(height: 20),
          //Bottom
          Obx(
            () => Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xff7AD081),
                borderRadius: BorderRadius.circular(30),
              ),
              child: MaterialButton(
                onPressed: () async {
                  controller.isLoading.value = true;
                  final res = await ApiService.instance.patch(
                    ApiConstants.volunteerPageThree,
                    requiresAuth: true,
                    body: {
                      "skills": controller.skillsController.text,
                      "languages": controller.languagesThree.text,
                      "previous_experience":
                          controller.experienceController.text,
                      "education_level": controller.education.text,
                    },
                  );
                  controller.isLoading.value = false;

                  if (!res.isSuccess) {
                    Get.snackbar(
                      "Failed to save",
                      res.errorMessage ?? "Please try again.",
                      colorText: Colors.red,
                    );
                    return;
                  }
                  Get.to(() => Pagefore());
                },
                child: controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
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

  // ðŸ”¹ TextField
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
