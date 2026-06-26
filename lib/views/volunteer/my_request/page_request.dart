import 'package:aidora/views/volunteer/my_request/rejected.dart';
import 'package:aidora/views/volunteer/my_request/approved.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/views/volunteer/navigation/vol_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

class Pagerequest extends StatefulWidget {
  const Pagerequest({super.key});
  @override
  State<StatefulWidget> createState() => _Pagerequest();
}

class _Pagerequest extends State<Pagerequest> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkUserRequest();
  }

  Future<void> _checkUserRequest() async {
    if (!mounted) return;
    setState(() { _checking = true; });

    final res = await ApiService.instance.get(
      ApiConstants.volunteerStateRequest,
      requiresAuth: true,
    );

    // -------------- State --------------
    if (!mounted) return;

    if (!res.isSuccess) {
      // Could not reach server — let the user retry instead of being stuck silently
      setState(() { _checking = false; });
      Get.snackbar(
        "Connection issue",
        res.errorMessage ?? "Could not check your request status.",
        colorText: Colors.red,
      );
      return;
    }

    final data = res.data as Map<String, dynamic>? ?? {};
    final profileCompleted = data['profile_completed'] == true;
    final status = (data['application_status'] ?? '').toString().toLowerCase();

    if (profileCompleted) {
      // Profile done and approved → main volunteer area
      Get.offAll(() => const Navigationbarr(), transition: Transition.fadeIn);
    } else if (status == 'approved') {
      Get.offAll(() => Approved());
    } else if (status == 'rejected') {
      Get.offAll(() => Rejected());
    } else {
      // pending/null → stay on this page
      setState(() { _checking = false; });
    }
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
                child: Column(
                  children: [
                    _formCard(),
                    if (!_checking) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _checkUserRequest,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Check Again"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerImage() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Image.asset(
        "images/Waiting-pana (1) 1.png",
        height: 300,
        width: 400,
      ),
    );
  }
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
          width: 150,
          color: Color(0x00E5E7EB),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: Color(0xff7ad081)),
                SizedBox(width: 10),
                Text(
                  "Processing",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff7ad081),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Your request has been submitted",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 10),
        Text(
          "We are currently reviewing your application details. You will be notified immediately once a decision has been made.",
          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 20, color: Colors.blueGrey),
        ),

        SizedBox(height: 30),



      ],
    ),
  );
}
