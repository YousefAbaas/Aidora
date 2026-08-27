import 'package:aidora/views/volunteer/navigation/vol_all_task.dart';
import 'package:aidora/views/volunteer/navigation/vol_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/controllers/vol_controller.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/views/volunteer/navigation/vol_home_page.dart';

class Navigationbarr extends StatefulWidget {
  const Navigationbarr({super.key});

  @override
  State<StatefulWidget> createState() => _Navigationbar();
}

class _Navigationbar extends State<Navigationbarr> {
  final FormController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Controllers are pre-registered in main.dart initialBinding.
    VolController.to.loadProfile();
    NotificationService.to.fetchFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xffF4F6F5),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [HomePage(), Alltask(), ProfilePage()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.changePage(index),
          selectedItemColor: const Color.fromARGB(255, 3, 95, 6),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
