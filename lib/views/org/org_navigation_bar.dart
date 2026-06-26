import 'package:aidora/views/org/org_fore/org_fore.dart';
import 'package:aidora/views/org/org_one/org_one.dart';
import 'package:aidora/views/org/org_three/org_three.dart';
import 'package:aidora/views/org/org_two/org_two.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_storage.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/views/notifications_screen.dart';
import 'package:aidora/views/selection_screen.dart';
import 'package:aidora/controllers/org_controller.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/widgets/org_logo_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orgnavigationbar extends StatefulWidget {
  const Orgnavigationbar({super.key});
  @override
  State<StatefulWidget> createState() => _Orgnavigationbar();
}

class _Orgnavigationbar extends State<Orgnavigationbar> {
  final FormController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Controllers are pre-registered in main.dart initialBinding.
    // Just reload data for this session (token is now valid).
    OrgController.to.loadProfile();
    NotificationService.to.fetchFromApi();
  }

  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Log Out'),
        ),
      ],
    ));
    if (confirmed != true) return;
    await ApiService.instance.post(
      ApiConstants.logout, requiresAuth: true,
      body: {'refresh': AuthStorage.getRefreshToken() ?? ''},
    );
    await AuthStorage.clear();
    Get.offAll(() => const SelectionScreen(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo + Name (fully reactive) ────────────────────
              Row(children: [
                const OrgLogoAvatar(size: 42),
                const SizedBox(width: 12),
                Obx(() => Text(
                  OrgController.to.orgName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.w700,
                  ),
                )),
              ]),

              // ── Notifications + Logout ───────────────────────────
              Row(children: [
                // Bell with badge
                Obx(() {
                  final count = NotificationService.to.unreadCount.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Get.to(
                          () => const NotificationsScreen(),
                          transition: Transition.cupertino,
                        ),
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFF2C3E3C)),
                        tooltip: 'Notifications',
                      ),
                      if (count > 0)
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFE74C3C)),
                  tooltip: 'Log Out',
                ),
              ]),
            ],
          ),
        ),
        backgroundColor: const Color(0xffF4F6F5),
        body: IndexedStack(
          index: controller.orgCurrentIndex.value,
          children: const [Orgone(), Orgtwo(), Orgthree(), Orgfore()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.orgCurrentIndex.value,
          onTap: (index) => controller.changOrgCurrentIndex(index),
          selectedItemColor: const Color(0xFF2C5F4F),
          unselectedItemColor: Colors.grey,
          unselectedFontSize: 12,
          selectedFontSize: 12,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_turned_in_rounded),
                label: 'Requests'),
            BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: 'Volunteers'),
          ],
        ),
      ),
    );
  }
}
