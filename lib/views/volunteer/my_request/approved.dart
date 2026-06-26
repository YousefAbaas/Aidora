import 'package:aidora/views/volunteer/my_request/pinput_example.dart';
import 'package:aidora/views/volunteer/navigation/vol_navigation_bar.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Approved extends StatefulWidget {
  const Approved({super.key});

  @override
  State<StatefulWidget> createState() => _Approved();
}

class _Approved extends State<Approved> {
  @override
  void initState() {
    super.initState();
  }

  final FormController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xffF4F4F4),
        body: Column(
          children: [
            _headerImage(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: _formCard(context),
              ),
            ),
            _logOut(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _headerImage() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Image.asset(
        "images/Good team-cuate 1.png",
        height: 300,
        width: 400,
      ),
    );
  }

  Widget _logOut() {
    return GestureDetector(
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

            final verifyRes = await ApiService.instance.post(
              ApiConstants.verifyPin,
              requiresAuth: true,
              body: {"pin": controller.pinCode.value},
            );

            if (!verifyRes.isSuccess) {
              controller.isLoading.value = false;
              Get.snackbar(
                "Invalid PIN",
                verifyRes.errorMessage ?? "Please check the code and try again.",
                colorText: Colors.red,
              );
              return;
            }

            final check = await ApiService.instance.get(
              ApiConstants.volunteerStateRequest,
              requiresAuth: true,
            );
            controller.isLoading.value = false;

            if (!check.isSuccess) {
              Get.snackbar(
                "Connection issue",
                check.errorMessage ?? "Could not verify your status.",
                colorText: Colors.red,
              );
              return;
            }

            if (check.data['profile_completed'] == true &&
                check.data['application_status'] == 'approved') {
              Get.offAll(() => Navigationbarr());
            } else {
              Get.snackbar(
                "Not ready yet",
                "Your profile setup isn't complete yet.",
                colorText: Colors.orange,
              );
            }
          },
          child: controller.isLoading.value
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  "Verify & Continue",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
        ),
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your request has been approved, Enter the PIN code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),
          // هون حطيت ال text field
          FractionallySizedBox(
            widthFactor: 1,
            // You can also checkout the [PinputBuilderExample]
            child: PinputExample(),
          ),

          SizedBox(height: 30),
          TextButton(
            onPressed: () async {
              final res = await ApiService.instance.post(
                ApiConstants.resendPin,
                requiresAuth: true,
                body: {},
              );
              if (res.isSuccess) {
                Get.snackbar(
                  "Code sent",
                  "A new PIN code has been sent.",
                  colorText: Colors.green,
                );
              } else {
                Get.snackbar(
                  "Failed to resend",
                  res.errorMessage ?? "Please try again.",
                  colorText: Colors.red,
                );
              }
            },
            child: Text(
              "Resend code ?",
              style: TextStyle(
                color: Color(0xff2d6a4f),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
