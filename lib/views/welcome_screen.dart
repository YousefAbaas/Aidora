import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import 'organizations_list_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'img/logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.volunteer_activism,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Welcome to Aidora',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Connect with humanitarian organizations\nand get the help you need',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Guest Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(
                    () => const OrganizationsListScreen(),
                    transition: Transition.cupertino,
                  ),
                  icon: const Icon(Icons.person_outline_rounded, size: 20),
                  label: Text('Continue as Guest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.35),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Login button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(
                    () => const LoginScreen(),
                    transition: Transition.cupertino,
                  ),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text('Log In to Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
