import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;
  bool _sent       = false;

  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg    = Color(0xFFF5F3ED);

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack('enter_email_hint'.tr, isError: true); return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final r = await AuthService.instance.forgotPassword(email: email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (r.isSuccess) {
      setState(() => _sent = true);
    } else {
      _snack(r.errorMessage ?? 'Request failed.', isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    // Truncate to prevent snackbar overflow
    final display = msg.length > 120 ? '\${msg.substring(0, 120)}…' : msg;
    Get.snackbar(
      isError ? 'Error' : '✓', display,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red[50] : _green.withOpacity(0.12),
      colorText: isError ? Colors.red[800] : _green,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      maxWidth: 480,
      messageText: Text(
        display,
        style: TextStyle(fontSize: 13, color: isError ? Colors.red[800] : _green),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: _green),
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: _green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_rounded, color: _green, size: 40),
            ),
            const SizedBox(height: 24),
            Text('forgot_password_title'.tr,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E28))),
            const SizedBox(height: 10),
            Text(
              _sent
                  ? '${'check_email_sub'.tr}\n${_emailCtrl.text.trim()}'
                  : 'forgot_password_sub'.tr,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!_sent) ...[ 
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _isLoading ? null : _send(),
                  decoration: InputDecoration(
                    hintText: 'enter_email_hint'.tr,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.email_outlined, color: _green),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: _green.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('send_reset_link'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _green.withOpacity(0.2)),
                ),
                child: Column(children: [
                  const Icon(Icons.mark_email_read_rounded, color: _green, size: 48),
                  const SizedBox(height: 12),
                  Text('check_email'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E28))),
                  const SizedBox(height: 8),
                  Text('check_email_sub'.tr,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                      textAlign: TextAlign.center),
                ]),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => _sent = false),
                child: Text('resend_link'.tr,
                    style: const TextStyle(color: _green, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('back_to_login'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ),
          ]),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
