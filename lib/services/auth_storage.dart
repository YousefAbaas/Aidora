import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// AuthStorage â€” bulletproof persistent token store.
/// Uses SharedPreferences (works on all platforms incl. Web).
/// Safe to call getters even before init() â€” returns null gracefully.
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AuthStorage {
  AuthStorage._();

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kRole = 'auth_role';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_display_name';

  static SharedPreferences? _prefs;

  // â”€â”€ Init (called once in main before runApp) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('ðŸ”‘ AuthStorage ready â€” '
          'loggedIn=$isLoggedIn  role=${getRole()}  name=${getName()}');
    } catch (e) {
      debugPrint('âŒ AuthStorage.init error: $e');
    }
  }

  // â”€â”€ Ensure prefs loaded (lazy fallback) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // â”€â”€ Save all tokens + user info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
    String? email,
    String? displayName,
  }) async {
    final p = await _ensurePrefs();
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
    await p.setString(_kRole, role);
    if (email != null && email.isNotEmpty) await p.setString(_kEmail, email);
    if (displayName != null && displayName.isNotEmpty)
      await p.setString(_kName, displayName);
    debugPrint('ðŸ”‘ Tokens saved â€” role=$role  name=$displayName');
  }

  // â”€â”€ Update access token after refresh â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> updateAccessToken(String token) async {
    final p = await _ensurePrefs();
    await p.setString(_kAccess, token);
    debugPrint('ðŸ”‘ Access token updated');
  }

  // â”€â”€ Save display name separately (called after profile load) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> saveName(String name) async {
    if (name.isEmpty) return;
    final p = await _ensurePrefs();
    await p.setString(_kName, name);
  }

  // â”€â”€ Synchronous getters (null-safe) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static String? getAccessToken() => _prefs?.getString(_kAccess);
  static String? getRefreshToken() => _prefs?.getString(_kRefresh);
  static String? getRole() => _prefs?.getString(_kRole);
  static String? getUserEmail() => _prefs?.getString(_kEmail);
  static String? getName() => _prefs?.getString(_kName);

  static bool get isLoggedIn {
    final t = getAccessToken();
    return t != null && t.isNotEmpty;
  }

  // â”€â”€ Clear on logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> clear() async {
    final p = await _ensurePrefs();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kRole);
    await p.remove(_kEmail);
    await p.remove(_kName);
    debugPrint('ðŸ”‘ All tokens cleared');
  }
}
