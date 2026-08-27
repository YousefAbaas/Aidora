import 'package:aidora/views/volunteer/form/page_two.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Pageone extends StatefulWidget {
  const Pageone({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Pageone();
  }
}

class _Pageone extends State<Pageone> {
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
                  onPressed: () {},
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text("VOLUNTEERING", style: TextStyle(color: Colors.white70)),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "Almost there!\nTell us more.",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Step 1 of 5 Identity & Residence",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// ================= FORM =================
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
          // Date of birth
          Text("Date of birth", style: _title()),

          Row(
            children: [
              _dropdownReactive(
                controller.month,
                controller.months,
                controller.setMonth,
              ),
              SizedBox(width: 10),
              _dropdownReactive(
                controller.day,
                controller.days,
                controller.setDay,
              ),
              SizedBox(width: 10),
              _dropdownReactive(
                controller.year,
                controller.years,
                controller.setYear,
              ),
            ],
          ),

          SizedBox(height: 15),
          // Gender
          Text("Gender", style: _title()),
          Obx(
            () => _inputBox(
              text: controller.gender.value,
              onTap: () => _showGenderSheet(),
            ),
          ),

          SizedBox(height: 15),
          // ðŸ”¹ Nationality
          _section(
            title: "Nationality",
            child: _textField(
              controller: controller.nationality,
              hint: "Switzerland",
              icon: Icons.public_rounded,
            ),
          ), // ðŸ”¹ID / Passport number
          _section(
            title: "ID / Passport number",
            child: _textField(
              controller: controller.idController,
              hint: "Enter identification number",
              icon: Icons.badge_outlined,
            ),
          ), // ðŸ”¹ Current city
          _section(
            title: "Current city",
            child: _textField(
              controller: controller.cityController,
              hint: "Where do you live",
              icon: Icons.place_sharp,
            ),
          ),
          SizedBox(height: 25),

          /// BUTTON
          Obx(
            () => GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Color(0xff7AD081),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: MaterialButton(
                  onPressed: () async {
                    controller.isLoading.value = true;
                    controller.returnDate(
                      controller.year.value,
                      controller.months.indexOf(controller.month.value) + 1,
                      int.parse(controller.day.value),
                    );
                    final res = await ApiService.instance.patch(
                      ApiConstants.volunteerPageOne,
                      requiresAuth: true,
                      body: {
                        "gender": controller.gender.value,
                        "date_of_birth": controller.date.value,
                        "current_city": controller.cityController.text,
                        "nationality": controller.nationality.text,
                        "id_number": controller.idController.text,
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
                    Get.to(() => Pagetwo());
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
          ),
        ],
      ),
    );
  }

  /// ================= DROPDOWN =================
  Widget _dropdownReactive(
    RxString selected,
    List<String> items,
    Function(String) onSelect,
  ) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () {
            Get.bottomSheet(
              barrierColor: Colors.transparent,
              elevation: 0,
              Container(
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  children: items.map((e) {
                    return ListTile(
                      title: Text(e),
                      onTap: () {
                        onSelect(e);
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
          child: Container(
            height: 55,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(selected.value), Icon(Icons.keyboard_arrow_down)],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= INPUT =================
  Widget _inputBox({
    required String text,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Color(0xffF6F6F6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Color(0xff7AD081)),
            if (icon != null) SizedBox(width: 10),
            Text(text),
            Spacer(),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  TextStyle _title() => TextStyle(fontWeight: FontWeight.bold, fontSize: 14);

  /// ================= GENDER SHEET =================
  void _showGenderSheet() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      elevation: 0,
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.genders.map((g) {
            return ListTile(
              title: Text(g),
              onTap: () {
                controller.setGender(g);
                Get.back();
              },
            );
          }).toList(),
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
}
