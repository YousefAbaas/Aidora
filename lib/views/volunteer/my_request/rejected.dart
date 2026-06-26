import 'package:aidora/views/login_screen.dart';
import 'package:aidora/views/selection_screen.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

// ignore: must_be_immutable
class Rejected extends StatelessWidget {
  Rejected({super.key});

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
                child: _formCard(),
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
      child: Image.asset("images/Notify-amico 1.png", height: 300, width: 400),
    );
  }

  Widget _logOut() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 206, 206, 206),
        borderRadius: BorderRadius.circular(30),
      ),
      child: MaterialButton(
        onPressed: () async {
          controller.isLoading.value = true;
          await ApiService.instance.post(
            ApiConstants.logout,
            requiresAuth: true,
            body: {"refresh": AuthStorage.getRefreshToken()},
          );
          controller.isLoading.value = false;
          await AuthService.instance.logout();
          // After rejection → guest mode: show organizations list
          Get.offAll(() => const SelectionScreen(), transition: Transition.fadeIn);
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: controller.isLoading.value
              ? CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 50, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Log Out", style: TextStyle(color: Colors.blueGrey)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffF4F4F4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.remove_circle_outline_rounded,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Your request has been rejected.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),
          Text(
            "Please review your details or contact support for further assistance regarding this application.",
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 20, color: Colors.blueGrey),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}
