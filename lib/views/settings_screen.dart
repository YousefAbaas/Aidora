import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../utils/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SettingsScreen
/// Accessible from the Profile screen gear icon (top-right).
/// Provides: Language toggle · Dark/Light mode · Privacy mode
/// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        title: Text('settings'.tr,
            style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final sc = SettingsController.to;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Appearance section ─────────────────────────────────────
            _sectionHeader(context, 'appearance'.tr),
            const SizedBox(height: 12),

            // Dark mode
            _settingCard(
              context: context,
              icon: sc.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              iconColor: sc.isDark ? const Color(0xFF7986CB) : const Color(0xFFFFA726),
              title: 'dark_mode'.tr,
              subtitle: 'dark_mode_sub'.tr,
              trailing: Switch.adaptive(
                value: sc.isDark,
                onChanged: (_) => sc.toggleTheme(),
                activeColor: context.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),

            // Language
            _settingCard(
              context: context,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF26A69A),
              title: 'language'.tr,
              subtitle: 'language_sub'.tr,
              trailing: GestureDetector(
                onTap: sc.toggleLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(sc.isArabic ? 'EN' : 'عر',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(width: 6),
                    const Icon(Icons.swap_horiz_rounded,
                        color: Colors.white, size: 16),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Privacy section ────────────────────────────────────────
            _sectionHeader(context, 'privacy_mode'.tr),
            const SizedBox(height: 12),

            _settingCard(
              context: context,
              icon: sc.privacyMode
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              iconColor: sc.privacyMode
                  ? const Color(0xFFE53935)
                  : const Color(0xFF43A047),
              title: 'privacy_mode'.tr,
              subtitle: 'privacy_mode_sub'.tr,
              trailing: Switch.adaptive(
                value: sc.privacyMode,
                onChanged: (_) => sc.togglePrivacy(),
                activeColor: Colors.red[600],
              ),
            ),

            if (sc.privacyMode) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sc.isArabic
                          ? 'وضع الخصوصية مفعّل — البيانات الحساسة مخفية'
                          : 'Privacy mode active — sensitive data is masked',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.red),
                    ),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 32),

            // App version
            Center(
              child: Text('Aidora v1.0.0',
                  style: TextStyle(
                      fontSize: 12, color: context.textSub)),
            ),
          ],
        );
      }),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionHeader(BuildContext context, String title) => Text(
    title,
    style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: context.primaryGreen,
        letterSpacing: 0.5),
  );

  Widget _settingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: context.shadowColor.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textColor)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: context.textSub)),
            ],
          ),
        ),
        trailing,
      ]),
    );
  }
}
