import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// RegisterScreen  (API-connected)
/// POST /register/refugee/
/// Body: {full_name, phone_number, email, password, confirm_password, accept_terms}
///
/// Backend error handling:
///   - {"non_field_errors": ["Passwords do not match"]}
///   - {"non_field_errors": ["You must accept the terms and conditions"]}
///   - {"message": "Refugee account created"}  → success
/// ─────────────────────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _acceptTerms    = false;

  // Field error states (inline validation)
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg    = Color(0xFFF5F3ED);
  static const Color _red   = Color(0xFFD32F2F);

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Client-side validation ─────────────────────────────────────────────────
  bool _validateLocally() {
    bool ok = true;

    setState(() {
      _nameError    = _nameCtrl.text.trim().isEmpty  ? 'Full name is required'   : null;
      _phoneError   = _phoneCtrl.text.trim().isEmpty ? 'Phone number is required': null;
      _emailError   = _emailCtrl.text.trim().isEmpty ? 'Email is required'       : null;
      _passError    = _passwordCtrl.text.length < 6  ? 'At least 6 characters'   : null;
      _confirmError = (_confirmCtrl.text != _passwordCtrl.text)
                        ? 'Passwords do not match' : null;
    });

    if (_nameError != null || _phoneError != null || _emailError != null ||
        _passError != null || _confirmError != null) ok = false;

    if (!_acceptTerms) {
      _showSnack('يجب قبول الشروط والأحكام للمتابعة\nYou must accept the terms and conditions.',
          isError: true);
      ok = false;
    }

    return ok;
  }

  // ── API call ───────────────────────────────────────────────────────────────
  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_validateLocally()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.instance.registerRefugee(
      fullName:        _nameCtrl.text.trim(),
      phoneNumber:     _phoneCtrl.text.trim(),
      email:           _emailCtrl.text.trim(),
      password:        _passwordCtrl.text,
      confirmPassword: _confirmCtrl.text,
      acceptTerms:     _acceptTerms,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Navigate to OTP screen with email from server response
      Get.off(() => OtpVerificationScreen(email: result.email),
          transition: Transition.fadeIn);
    } else {
      final msg = result.errorMessage ?? 'Registration failed.';
      _showSnack(msg, isError: true);
      if (msg.contains('Passwords do not match') || msg.contains('password')) {
        setState(() => _confirmError = msg);
      }
    }
  }

  void _showSnack(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Success ✓',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red[50]! : _green,
      colorText: isError ? _red : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      maxWidth: 400,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      messageText: Text(
        message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: isError ? _red : Colors.white,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: _green, size: 22),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Create Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green)),
                  ),
                ),
                const SizedBox(width: 48),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Create your\nRefugee Account',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2E28), height: 1.25)),
                  const SizedBox(height: 8),
                  Text('Fill in the information below to register',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 28),

                  // ── Full Name ───────────────────────────────────────────
                  _label('Full Name'),
                  _field(
                    controller: _nameCtrl,
                    hint: 'e.g. Ali Ahmed',
                    icon: Icons.person_outline,
                    error: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 16),

                  // ── Phone ───────────────────────────────────────────────
                  _label('Phone Number'),
                  _field(
                    controller: _phoneCtrl,
                    hint: 'e.g. 0933xxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    error: _phoneError,
                    onChanged: (_) => setState(() => _phoneError = null),
                  ),
                  const SizedBox(height: 16),

                  // ── Email ───────────────────────────────────────────────
                  _label('Email'),
                  _field(
                    controller: _emailCtrl,
                    hint: 'e.g. ali@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    error: _emailError,
                    onChanged: (_) => setState(() => _emailError = null),
                  ),
                  const SizedBox(height: 16),

                  // ── Password ────────────────────────────────────────────
                  _label('Password'),
                  _field(
                    controller: _passwordCtrl,
                    hint: 'Min 6 characters',
                    icon: Icons.lock_outline,
                    obscure: _obscurePass,
                    error: _passError,
                    onChanged: (_) => setState(() => _passError = null),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey[600], size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm Password ────────────────────────────────────
                  _label('Confirm Password'),
                  _field(
                    controller: _confirmCtrl,
                    hint: 'Re-enter password',
                    icon: Icons.lock_outline,
                    obscure: _obscureConfirm,
                    error: _confirmError,
                    onChanged: (_) => setState(() => _confirmError = null),
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey[600], size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Accept Terms checkbox ───────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _acceptTerms
                            ? _green.withOpacity(0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _acceptTerms ? _green : Colors.grey[300]!,
                          width: _acceptTerms ? 1.5 : 1,
                        ),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: _acceptTerms ? _green : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _acceptTerms ? _green : Colors.grey[400]!,
                              width: 1.5,
                            ),
                          ),
                          child: _acceptTerms
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                              children: [
                                const TextSpan(
                                    text: 'I consent to use my personal data for '),
                                TextSpan(
                                  text: 'humanitarian assistance purposes',
                                  style: TextStyle(
                                      color: _green, fontWeight: FontWeight.w600),
                                ),
                                const TextSpan(text: ' and accept the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                      color: _green, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Register Button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        disabledBackgroundColor: _green.withOpacity(0.55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Already have an account? Login',
                          style: TextStyle(color: Colors.blue, fontSize: 14)),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3A))),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? error,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null ? _red : Colors.transparent,
            width: error != null ? 1.5 : 0,
          ),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
            suffixIcon: suffix,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            filled: true, fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(error,
              style: const TextStyle(
                  fontSize: 12, color: _red, fontWeight: FontWeight.w500)),
        ),
    ]);
  }
}
