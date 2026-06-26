import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import 'organizations_list_screen.dart';
import 'login_screen.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - MediaQuery.of(context).padding.bottom
                  - 32,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),

                  // ── Floating icon ──────────────────────────────────────
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C5F4F).withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF2C5F4F).withOpacity(
                                0.15 + (_floatAnim.value.abs() / 14) * 0.1),
                            blurRadius: 20 + _floatAnim.value.abs(),
                            spreadRadius: 2,
                            offset: Offset(0, 4 - _floatAnim.value * 0.3),
                          )],
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded,
                            size: 50, color: Color(0xFF2C5F4F)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text('Welcome to Aidora',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('How would you like to continue?',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 36),

                  // ── Organization ─────────────────────────────────────
                  _OptionCard(
                    icon:     Icons.business_rounded,
                    title:    'Organization',
                    subtitle: 'For official NGOs and aid providers\nlooking to manage resources.',
                    onTap: () => Get.to(
                      () => const LoginScreen(role: 'org'),
                      transition: Transition.cupertino,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Guest ────────────────────────────────────────────
                  _OptionCard(
                    icon:     Icons.person_rounded,
                    title:    'Continue as Guest',
                    subtitle: 'Explore available aid services and\nresources without signing up.',
                    onTap: () => Get.to(() => const OrganizationsListScreen(),
                        transition: Transition.cupertino),
                  ),

                  const Spacer(),

                  // ── Login link ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        TextButton(
                          onPressed: () => Get.to(() => const LoginScreen(),
                              transition: Transition.cupertino),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Log in',
                              style: TextStyle(fontSize: 14,
                                  color: Color(0xFF2C5F4F),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final VoidCallback onTap;
  const _OptionCard({
    required this.icon, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          )],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5F4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2C5F4F), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5F4F))),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 22),
        ]),
      ),
    );
  }
}
