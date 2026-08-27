import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  /// 'volunteer' â†’ calls registerVolunteer endpoint; otherwise registerRefugee
  final String? role;
  const SignUpScreen({super.key, this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  String? _nameError;
  String? _emailError;
  String? _passError;

  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg = Color(0xFFF5F3ED);
  static const Color _white = Colors.white;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Name is required' : null;
      _emailError =
          !_emailCtrl.text.contains('@') ? 'Enter a valid email' : null;
      _passError = _passwordCtrl.text.length < 6 ? 'Min 6 characters' : null;
      if (_passwordCtrl.text != _confirmCtrl.text) {
        _passError = 'Passwords do not match';
      }
    });
    if (_nameError != null || _emailError != null || _passError != null)
      ok = false;
    if (!_acceptTerms) {
      Get.snackbar(
          'Consent Required', 'Please accept the data consent to continue.',
          backgroundColor: Colors.orange[400],
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          borderRadius: 12,
          margin: const EdgeInsets.all(12));
      ok = false;
    }
    return ok;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _isLoading = true);

    final isVolunteer = widget.role == 'volunteer';
    final result = isVolunteer
        ? await AuthService.instance.registerVolunteer(
            fullName: _nameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            confirmPassword: _confirmCtrl.text,
            acceptTerms: _acceptTerms,
          )
        : await AuthService.instance.registerRefugee(
            fullName: _nameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            confirmPassword: _confirmCtrl.text,
            acceptTerms: _acceptTerms,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      Get.off(
          () => OtpVerificationScreen(email: result.email, role: widget.role),
          transition: Transition.fadeIn);
    } else {
      Get.snackbar('Error', result.errorMessage ?? 'Registration failed.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[50],
          colorText: Colors.red[800],
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(children: [
            // â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: _green, size: 22),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Aidora',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _green,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create your\nVolunteer Account',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A2E28),
                              height: 1.25)),
                      const SizedBox(height: 8),
                      Text(
                          'Fill in your information to register as a volunteer',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 28),

                      // Full name
                      _label('Full Name'),
                      _field(
                          controller: _nameCtrl,
                          hint: 'e.g. Sara Ahmed',
                          icon: Icons.person_outline,
                          error: _nameError),
                      const SizedBox(height: 16),

                      // Phone
                      _label('Phone Number'),
                      _field(
                          controller: _phoneCtrl,
                          hint: '+963 XXX XXX',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),

                      // Email
                      _label('Email'),
                      _field(
                          controller: _emailCtrl,
                          hint: 'name@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          error: _emailError),
                      const SizedBox(height: 16),

                      // Password
                      _label('Password'),
                      _field(
                          controller: _passwordCtrl,
                          hint: 'Min 6 characters',
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          error: _passError,
                          suffix: IconButton(
                            icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[600],
                                size: 20),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          )),
                      const SizedBox(height: 16),

                      // Confirm password
                      _label('Confirm Password'),
                      _field(
                          controller: _confirmCtrl,
                          hint: 'Repeat password',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffix: IconButton(
                            icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[600],
                                size: 20),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          )),
                      const SizedBox(height: 24),

                      // Data consent
                      GestureDetector(
                        onTap: () =>
                            setState(() => _acceptTerms = !_acceptTerms),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (v) =>
                                    setState(() => _acceptTerms = v ?? false),
                                activeColor: _green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'I agree to the Terms & Conditions and consent to data processing.',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 28),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            disabledBackgroundColor:
                                _green.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('Create Volunteer Account',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Already have account
                      Center(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Already have an account? Login',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: _green,
                                  fontWeight: FontWeight.w600)),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700])),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? error,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: error != null ? Colors.red[300]! : Colors.transparent),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixIcon: suffix,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: _white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(error,
              style: TextStyle(fontSize: 12, color: Colors.red[700])),
        ),
    ]);
  }
}
