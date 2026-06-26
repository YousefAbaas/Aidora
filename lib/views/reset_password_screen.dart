import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String uid;
  final String token;
  const ResetPasswordScreen({super.key, required this.uid, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _passError;

  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg    = Color(0xFFF5F3ED);

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _passError = null);
    final pass    = _newPassCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pass.length < 6) {
      setState(() => _passError = 'min_6_chars'.tr);
      return;
    }
    if (pass != confirm) {
      setState(() => _passError = 'confirm_password'.tr);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final r = await AuthService.instance.resetPassword(
      uid:             widget.uid,
      token:           widget.token,
      newPassword:     pass,
      confirmPassword: confirm,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (r.isSuccess) {
      Get.snackbar(
        '✓', 'save_password'.tr,
        backgroundColor: _green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Get.offAll(() => const LoginScreen(), transition: Transition.fadeIn);
    } else {
      final errMsg = r.errorMessage ?? 'Request failed.';
      final display = errMsg.length > 120 ? '\${errMsg.substring(0, 120)}…' : errMsg;
      Get.snackbar(
        'Error', display,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        isDismissible: true,
        duration: const Duration(seconds: 3),
        messageText: Text(
          display,
          style: TextStyle(fontSize: 13, color: Colors.red[800]),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      // resizeToAvoidBottomInset ensures keyboard doesn't cause overflow
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // keyboardDismissBehavior dismisses keyboard on scroll
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                // At minimum, fill the available height so content is centered
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // ── Icon ────────────────────────────────────────────────
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_open_rounded,
                            color: _green, size: 36),
                      ),
                      const SizedBox(height: 20),

                      // ── Title ───────────────────────────────────────────────
                      Text(
                        'create_new_password'.tr,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2E28)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'forgot_password_sub'.tr,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // ── New Password ─────────────────────────────────────────
                      _label('new_password'.tr),
                      _passField(
                        controller: _newPassCtrl,
                        hint:        'min_6_chars'.tr,
                        obscure:     _obscureNew,
                        hasError:    _passError != null,
                        toggle: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 14),

                      // ── Confirm Password ─────────────────────────────────────
                      _label('confirm_password'.tr),
                      _passField(
                        controller: _confirmCtrl,
                        hint:        'repeat_password'.tr,
                        obscure:     _obscureConfirm,
                        hasError:    _passError != null,
                        toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        onSubmitted: (_) => _isLoading ? null : _save(),
                      ),

                      // ── Error message ─────────────────────────────────────────
                      if (_passError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Row(children: [
                            const Icon(Icons.error_outline, size: 13, color: Colors.red),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(_passError!,
                                  style: const TextStyle(fontSize: 12, color: Colors.red)),
                            ),
                          ]),
                        ),

                      const SizedBox(height: 28),

                      // ── Save button ───────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            disabledBackgroundColor: _green.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Text(
                                  'save_password'.tr,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700])),
    ),
  );

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    bool hasError = false,
    ValueChanged<String>? onSubmitted,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasError
              ? Border.all(color: Colors.red[300]!, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: TextField(
          controller:      controller,
          obscureText:     obscure,
          textInputAction: onSubmitted != null
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: _green, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: toggle,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
}
