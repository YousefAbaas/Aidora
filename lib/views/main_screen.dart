import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/auth_storage.dart';
import 'home_screen.dart';
import 'requests_dashboard_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Load refugee profile from API once after login
    // so name + image are shown everywhere immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load profile — this sets displayName & apiImageUrl reactively
      // across HomeScreen, RequestsDashboard, and ProfileScreen
      ProfileController.to.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavController nav = Get.find<BottomNavController>();
    const screens = [
      HomeScreen(),
      RequestsDashboardScreen(),
      ProfileScreen(),
    ];
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: nav.selectedIndex.value,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: nav.selectedIndex.value,
            onTap: nav.changeTab,
            selectedItemColor: const Color(0xFF2C5F4F),
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.white,
            elevation: 12,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description_rounded),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}
