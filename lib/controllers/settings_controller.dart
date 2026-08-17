import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SettingsController  — single source of truth for app-wide settings.
///
/// Manages:
///   • Locale  (en / ar)
///   • ThemeMode (light / dark)
///   • Privacy mode (blur sensitive data)
///
/// All settings are persisted with SharedPreferences.
/// ─────────────────────────────────────────────────────────────────────────────
class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  static const _kLocale = 'locale';
  static const _kTheme = 'theme';
  static const _kPrivacy = 'privacy';

  // ── Reactive state ─────────────────────────────────────────────────────────
  final _locale = const Locale('en').obs;
  final _themeMode = ThemeMode.light.obs;
  final _privacyMode = false.obs;

  Locale get locale => _locale.value;
  ThemeMode get themeMode => _themeMode.value;
  bool get isDark => _themeMode.value == ThemeMode.dark;
  bool get isArabic => _locale.value.languageCode == 'ar';
  bool get privacyMode => _privacyMode.value;

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_kLocale) ?? 'en';
    final theme = prefs.getString(_kTheme) ?? 'light';
    final priv = prefs.getBool(_kPrivacy) ?? false;

    _locale.value = Locale(lang);
    _themeMode.value = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _privacyMode.value = priv;

    // 💡 التعديل هنا: تأجيل Get.updateLocale لما بعد انتهاء رسم الـ Frame لمنع تعارض الاختبارات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(_locale.value);
    });

    _applySystemUI();
  }

  // ── Language ───────────────────────────────────────────────────────────────
  Future<void> toggleLanguage() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, newLocale.languageCode);
    update(); // rebuild GetBuilder<SettingsController> in main.dart
  }

  // ── Dark / Light mode ──────────────────────────────────────────────────────
  Future<void> toggleTheme() async {
    _themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    _applySystemUI();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, isDark ? 'dark' : 'light');
    update(); // rebuild GetBuilder<SettingsController> in main.dart → changes ThemeMode
  }

  void _applySystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  // ── Privacy mode ───────────────────────────────────────────────────────────
  Future<void> togglePrivacy() async {
    _privacyMode.value = !_privacyMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacy, _privacyMode.value);
  }
}
