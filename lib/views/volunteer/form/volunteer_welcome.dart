import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'page_one.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome>
    with SingleTickerProviderStateMixin {
  final FormController _ctrl = Get.find();
  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();

    // Auto-navigate to Page One after 5 seconds
    _timer = Timer(const Duration(seconds: 5), _goToPageOne);
  }

  void _goToPageOne() {
    if (!mounted) return;
    Get.off(
      () => const Pageone(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    "images/Team work-bro 1.png",
                    height: 280, width: 360,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Thank you for your interest in helping.\nYour information enables us to guide you\nto the right role.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2C5F4F),
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Skip button
                TextButton.icon(
                  onPressed: _goToPageOne,
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Color(0xFF2C5F4F)),
                  label: const Text("Start Now",
                      style: TextStyle(fontSize: 16,
                          color: Color(0xFF2C5F4F),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 0 ? 20 : 8, height: 8,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? const Color(0xFF2C5F4F)
                          : const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
