import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import 'package:aidora/views/volunteer/my_request/page_request.dart';
import 'package:aidora/views/org/org_navigation_bar.dart';
import 'main_screen.dart';
import '../controllers/profile_controller.dart';
import '../controllers/bottom_nav_controller.dart';
import 'register_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

/// LoginScreen
///
/// [role] hint:
///   null       â†’ generic (refugee by default, routes by server role)
///   'volunteer' â†’ shows volunteer-specific UI, no "Create Account" refugee link
///   'org'       â†’ shows org-specific UI, no "Create Account" link
class LoginScreen extends StatefulWidget {
  /// Optional role hint: 'volunteer' | 'org' | null
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  static const Color _green = Color(0xFF2C5F4F);

  bool get _isVolunteer => widget.role == 'volunteer';
  bool get _isOrg => widget.role == 'org';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Login logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);
    final result =
        await AuthService.instance.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _routeByRole(result.role);
    } else {
      _showError(result.errorMessage ?? 'Login failed.');
    }
  }

  /// Route to the correct shell based on server role
  void _routeByRole(String serverRole) {
    switch (serverRole.toLowerCase()) {
      case 'volunteer':
        // Volunteer â†’ check application state then route
        Get.offAll(() => const Pagerequest(), transition: Transition.fadeIn);
        break;

      case 'org':
      case 'organization':
      case 'organizations':
        Get.offAll(() => const Orgnavigationbar(),
            transition: Transition.fadeIn);
        break;

      case 'refugee':
      default:
        // Refugee â†’ main shell
        final pc = Get.find<ProfileController>();
        pc.loadProfile();
        Get.find<BottomNavController>().changeTab(0);
        Get.offAll(() => const MainScreen(), transition: Transition.fadeIn);
        break;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Login Failed',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withValues(alpha: 0.12),
      colorText: Colors.red[800],
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // â”€â”€ Logo / Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              const Text('Aidora',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _green,
                      letterSpacing: 1.5)),

              if (_isVolunteer) ...[
                const SizedBox(height: 8),
                Text('Volunteer Login',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
              ] else if (_isOrg) ...[
                const SizedBox(height: 8),
                Text('Organization Login',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
              ],

              const SizedBox(height: 60),

              // â”€â”€ Email â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _fieldLabel('Username or email'),
              const SizedBox(height: 8),
              _inputBox(
                controller: _emailCtrl,
                hint: 'e.g. name@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // â”€â”€ Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _fieldLabel('Password'),
              const SizedBox(height: 8),
              _inputBox(
                controller: _passwordCtrl,
                hint: '\u2022' * 8,
                icon: Icons.lock_outline,
                obscure: _obscure,
                onSubmitted: (_) => _isLoading ? null : _login(),
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ForgotPasswordScreen(),
                      transition: Transition.cupertino),
                  child: const Text('Forgot password?',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 20),

              // â”€â”€ Login button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: _green.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Login',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),

              // â”€â”€ Create account (refugee & volunteer only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (!_isOrg) ...[
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Are you new? ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  TextButton(
                    onPressed: () => _isVolunteer
                        ? Get.to(() => const SignUpScreen(role: 'volunteer'),
                            transition: Transition.cupertino)
                        : Get.to(() => const RegisterScreen(),
                            transition: Transition.cupertino),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      _isVolunteer
                          ? 'Register as Volunteer'
                          : 'Create an Account',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child:
            Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onSubmitted,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction:
              onSubmitted != null ? TextInputAction.done : TextInputAction.next,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            suffixIcon: suffix,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );
}
