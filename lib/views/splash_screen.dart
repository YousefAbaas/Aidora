import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/auth_storage.dart';
import '../utils/app_theme.dart';
import 'main_screen.dart';
import 'onboarding_screens.dart';
import 'org/org_navigation_bar.dart';
import 'package:aidora/views/volunteer/my_request/page_request.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.75, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _decideRoute);
  }

  void _decideRoute() {
    if (!mounted) return;
    if (AuthStorage.isLoggedIn) {
      final role = AuthStorage.getRole()?.toLowerCase() ?? '';
      switch (role) {
        case 'org':
        case 'organization':
        case 'organizations':
          Get.offAll(() => const Orgnavigationbar(),
              transition: Transition.fadeIn);
          break;
        case 'volunteer':
          Get.offAll(() => const Pagerequest(), transition: Transition.fadeIn);
          break;
        case 'refugee':
        default:
          Get.find<ProfileController>().loadProfile();
          Get.find<BottomNavController>().changeTab(0);
          Get.offAll(() => const MainScreen(), transition: Transition.fadeIn);
          break;
      }
    } else {
      Get.offAll(() => const OnboardingScreen1(),
          transition: Transition.fadeIn);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: FadeTransition(
            opacity: _fade,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: const Icon(Icons.volunteer_activism_rounded,
                    size: 56, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('Aidora',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Humanitarian Aid Platform',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8))),
            ]),
          ),
        ),
      ),
    );
  }
}
