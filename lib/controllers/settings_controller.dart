import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// SettingsController  â€” single source of truth for app-wide settings.
///
/// Manages:
///   â€¢ Locale  (en / ar)
///   â€¢ ThemeMode (light / dark)
///   â€¢ Privacy mode (blur sensitive data)
///
/// All settings are persisted with SharedPreferences.
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  static const _kLocale = 'locale';
  static const _kTheme = 'theme';
  static const _kPrivacy = 'privacy';

  // â”€â”€ Reactive state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _locale = const Locale('en').obs;
  final _themeMode = ThemeMode.light.obs;
  final _privacyMode = false.obs;

  Locale get locale => _locale.value;
  ThemeMode get themeMode => _themeMode.value;
  bool get isDark => _themeMode.value == ThemeMode.dark;
  bool get isArabic => _locale.value.languageCode == 'ar';
  bool get privacyMode => _privacyMode.value;

  // â”€â”€ Init â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

    // ðŸ’¡ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„ Ù‡Ù†Ø§: ØªØ£Ø¬ÙŠÙ„ Get.updateLocale Ù„Ù…Ø§ Ø¨Ø¹Ø¯ Ø§Ù†ØªÙ‡Ø§Ø¡ Ø±Ø³Ù… Ø§Ù„Ù€ Frame Ù„Ù…Ù†Ø¹ ØªØ¹Ø§Ø±Ø¶ Ø§Ù„Ø§Ø®ØªØ¨Ø§Ø±Ø§Øª
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(_locale.value);
    });

    _applySystemUI();
  }

  // â”€â”€ Language â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> toggleLanguage() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, newLocale.languageCode);
    update(); // rebuild GetBuilder<SettingsController> in main.dart
  }

  // â”€â”€ Dark / Light mode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> toggleTheme() async {
    _themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    _applySystemUI();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, isDark ? 'dark' : 'light');
    update(); // rebuild GetBuilder<SettingsController> in main.dart â†’ changes ThemeMode
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

  // â”€â”€ Privacy mode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> togglePrivacy() async {
    _privacyMode.value = !_privacyMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacy, _privacyMode.value);
  }
}
