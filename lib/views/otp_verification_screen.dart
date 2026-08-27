import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'volunteer/form/volunteer_welcome.dart';

/// OTP Verification Screen
/// Shown after successful registration (refugee or volunteer).
/// Verifies account via POST /api/auth/verify-otp/
/// Resends OTP   via POST /api/auth/resend-otp/
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? role; // 'volunteer' â†’ route to Welcome after verify
  const OtpVerificationScreen({super.key, required this.email, this.role});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg = Color(0xFFF5F3ED);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendTimer > 0) _resendTimer--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String val) {
    if (val.length > 1) {
      // Paste handling: fill all boxes
      final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
      final clamped = digits.substring(0, digits.length.clamp(0, 6));
      for (int i = 0; i < clamped.length && i < 6; i++) {
        _controllers[i].text = clamped[i];
      }
      final next = (clamped.length - 1).clamp(0, 5);
      _focusNodes[next].requestFocus();
      setState(() {});
      // Auto-verify if all 6 pasted
      if (clamped.length == 6 && !_isVerifying) _verify();
      return;
    }
    if (val.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
    // Auto-verify when last box is filled
    if (index == 5 && val.isNotEmpty && _otp.length == 6 && !_isVerifying) {
      _verify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    final otp = _otp;
    if (otp.length < 6) {
      _showSnack('Please enter all 6 digits', isError: true);
      return;
    }
    setState(() => _isVerifying = true);
    final result = await AuthService.instance.verifyOtp(
      email: widget.email,
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (result.isSuccess) {
      Get.snackbar(
        'Account Verified âœ“',
        widget.role == 'volunteer'
            ? 'Verification successful. Starting your volunteer journey!'
            : 'Your account has been verified. Please login.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: _green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        if (widget.role == 'volunteer') {
          // Volunteer: go to Welcome screen (4s auto-advance to form)
          Get.offAll(() => const Welcome(), transition: Transition.fadeIn);
        } else {
          Get.offAll(() => const LoginScreen(), transition: Transition.fadeIn);
        }
      }
    } else {
      _showSnack(result.errorMessage ?? 'Invalid OTP. Please try again.',
          isError: true);
    }
  }

  Future<void> _resend() async {
    if (_resendTimer > 0) return;
    setState(() => _isResending = true);
    final result = await AuthService.instance.resendOtp(email: widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (result.isSuccess) {
      _showSnack('New OTP sent to ${widget.email}', isError: false);
      _startResendTimer();
      // clear old OTP
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } else {
      _showSnack(result.errorMessage ?? 'Failed to resend OTP.', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Sent âœ“',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          isError ? Colors.red[50]! : _green.withValues(alpha: 0.12),
      colorText: isError ? Colors.red[800] : _green,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? Colors.red : _green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_unread_rounded,
                    color: _green, size: 40),
              ),
              const SizedBox(height: 24),

              Text('verify_account'.tr,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E28))),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(widget.email,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C5F4F))),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    6,
                    (i) => _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (v) => _onDigitChanged(i, v),
                          onBackspace: () => _onBackspace(i),
                        )),
              ),

              const SizedBox(height: 36),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: _green.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('verify_btn'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // Resend
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('no_code'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: _green, strokeWidth: 2))
                    : GestureDetector(
                        onTap: _resendTimer == 0 ? _resend : null,
                        child: Text(
                          _resendTimer > 0
                              ? 'Resend in ${_resendTimer}s'
                              : 'resend'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _resendTimer == 0 ? _green : Colors.grey[400],
                          ),
                        ),
                      ),
              ]),

              const SizedBox(height: 32),

              // Back to login
              TextButton(
                onPressed: () => Get.offAll(() => const LoginScreen(),
                    transition: Transition.fadeIn),
                child: Text('back_to_login'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Single OTP digit box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  static const Color _green = Color(0xFF2C5F4F);

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? _green : Colors.grey[300]!,
          width: focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => onBackspace(),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E28)),
      ),
    );
  }
}
