import 'package:aidora/views/volunteer/form/page_three.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Pagetwo extends StatefulWidget {
  const Pagetwo({super.key});

  @override
  State<StatefulWidget> createState() => _Pagetwo();
}

class _Pagetwo extends State<Pagetwo> {
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
              SizedBox(width: 100),
              Icon(Icons.access_time, size: 100, color: Colors.white),
            ],
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              "when can you help?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              "Step 2 of 5: Identity & Residence",
              style: TextStyle(color: Colors.white70),
            ),
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
          Text(
            'Preferred schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          // Ø£Ø²Ø±Ø§Ø± Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¬Ø¯ÙˆÙ„
          Obx(
            () => Row(
              children: [
                _buildScheduleButton(
                  'Morning',
                  controller.selectedSchedule.value == 'Morning',
                ),
                const SizedBox(width: 12),
                _buildScheduleButton(
                  'Afternoon',
                  controller.selectedSchedule.value == 'Afternoon',
                ),
                const SizedBox(width: 12),
                _buildScheduleButton(
                  'Evening',
                  controller.selectedSchedule.value == 'Evening',
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Available days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 16),

          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  controller.availableDays.length,
                  (index) => _buildDayButton(
                    controller.availableDays[index],
                    controller.selectedDays.contains(
                      controller.availableDays[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),

          // ðŸ”¹ DD/MM/YYYY
          _section(
            title: "Start date",
            child: _textField(
              controller: controller.startDate,
              hint: "YYYY-MM-DD ex : 2024-02-09",
              icon: Icons.date_range,
            ),
          ),

          SizedBox(height: 24),

          // ðŸ”¹ Expected duration
          _section(
            title: "Expected duration",
            child: _textField(
              controller: controller.expectedDuration,
              hint: "e.g. 3 months",
              icon: Icons.timer_outlined,
            ),
          ),

          SizedBox(height: 20),

          Obx(
            () =>

                /// BUTTON
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
                  final res = await ApiService.instance.patch(
                    ApiConstants.volunteerPageTwo,
                    requiresAuth: true,
                    body: {
                      "availability_shift": controller.selectedSchedule.value,
                      "available_days": controller.selectedDays.toList(),
                      "start_date": controller.startDate.text,
                      "expected_duration": controller.expectedDuration.text,
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
                  Get.to(() => Pagethree());
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

  //////////////////////////////////////  methods  /////////////////////////////
  // Widget Ù„Ø²Ø± Ø§Ù„Ø¬Ø¯ÙˆÙ„ Ø§Ù„Ø²Ù…Ù†ÙŠ
  Widget _buildScheduleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectSchedule(text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xff7AD081) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(30),
            color: isSelected ? Color(0xff7AD081) : Colors.white,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Ù„Ø²Ø± Ø§Ù„ÙŠÙˆÙ…
  Widget _buildDayButton(String day, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.toggleDay(day),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Color(0xff7AD081) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xff7AD081) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
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

  // ...existing code...
}
