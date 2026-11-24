import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage boundary for authentication secrets.
///
/// The production implementation uses platform-backed secure storage
/// (Android Keystore, iOS Keychain, and the plugin's supported web backend).
/// This interface also allows deterministic tests without invoking platform
/// channels.
abstract interface class AuthTokenStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _FlutterSecureTokenStore implements AuthTokenStore {
  const _FlutterSecureTokenStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Owns the local authentication session.
///
/// Access and refresh tokens are stored in platform-backed secure storage.
/// Non-secret display metadata remains in SharedPreferences so existing
/// synchronous UI getters and settings behaviour remain compatible.
///
/// On upgrade, old token values are copied from SharedPreferences to secure
/// storage, read back and verified, and only then removed from the old store.
/// If migration fails, the old values are retained but are never used as a
/// plaintext fallback for authentication.
class AuthStorage {
  AuthStorage._();

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kRole = 'auth_role';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_display_name';

  static SharedPreferences? _prefs;
  static AuthTokenStore _tokenStore = const _FlutterSecureTokenStore();

  static String? _accessToken;
  static String? _refreshToken;
  static bool _initialized = false;
  static Future<void>? _initFuture;

  /// Loads the secure session and performs a one-time, verified migration
  /// from the previous SharedPreferences token keys.
  ///
  /// Initialization failure is fail-closed: no token is exposed to callers,
  /// plaintext legacy values are not deleted, and the app can still start so
  /// the user can retry by signing in.
  static Future<void> init() async {
    if (_initialized) return;

    final pending = _initFuture ??= _initialize();
    try {
      await pending;
    } catch (_) {
      _initFuture = null;
      _initialized = false;
      _accessToken = null;
      _refreshToken = null;
      debugPrint(
        'AuthStorage initialization failed; the saved session is unavailable.',
      );
    }
  }

  static Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    final legacyAccess = prefs.getString(_kAccess);
    final legacyRefresh = prefs.getString(_kRefresh);

    final access = await _readOrMigrateToken(
      key: _kAccess,
      legacyValue: legacyAccess,
    );
    final refresh = await _readOrMigrateToken(
      key: _kRefresh,
      legacyValue: legacyRefresh,
    );

    // Both secure reads/migrations have completed successfully. It is now
    // safe to remove the legacy plaintext token values.
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);

    _accessToken = access;
    _refreshToken = refresh;
    _initialized = true;
    debugPrint('AuthStorage ready; authentication secrets use secure storage.');
  }

  static Future<String?> _readOrMigrateToken({
    required String key,
    required String? legacyValue,
  }) async {
    final existing = await _tokenStore.read(key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    if (legacyValue == null || legacyValue.isEmpty) {
      return null;
    }

    await _tokenStore.write(key, legacyValue);
    final migrated = await _tokenStore.read(key);
    if (migrated != legacyValue) {
      throw StateError('Secure token migration verification failed.');
    }

    return migrated;
  }

  static Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Persists a new session. Tokens are verified in secure storage before
  /// non-secret user metadata is updated.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
    String? email,
    String? displayName,
  }) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError('Access and refresh tokens must not be empty.');
    }

    final prefs = await _ensurePrefs();

    try {
      await _tokenStore.write(_kAccess, accessToken);
      await _tokenStore.write(_kRefresh, refreshToken);

      final storedAccess = await _tokenStore.read(_kAccess);
      final storedRefresh = await _tokenStore.read(_kRefresh);
      if (storedAccess != accessToken || storedRefresh != refreshToken) {
        throw StateError('Secure token persistence could not be verified.');
      }

      // Remove legacy plaintext values after the secure copies are verified.
      await prefs.remove(_kAccess);
      await prefs.remove(_kRefresh);

      await prefs.setString(_kRole, role);
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_kEmail, email);
      }
      if (displayName != null && displayName.isNotEmpty) {
        await prefs.setString(_kName, displayName);
      }

      _accessToken = storedAccess;
      _refreshToken = storedRefresh;
      _initialized = true;
      debugPrint('AuthStorage saved a verified secure session.');
    } catch (_) {
      _accessToken = null;
      _refreshToken = null;
      await _deleteSecureTokensBestEffort();
      rethrow;
    }
  }

  /// Replaces the access token after a successful refresh.
  static Future<void> updateAccessToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Access token must not be empty.');
    }

    await _tokenStore.write(_kAccess, token);
    final stored = await _tokenStore.read(_kAccess);
    if (stored != token) {
      throw StateError('Secure access-token persistence could not be verified.');
    }

    _accessToken = stored;
  }

  /// Stores non-secret profile metadata separately from authentication tokens.
  static Future<void> saveName(String name) async {
    if (name.isEmpty) return;
    final prefs = await _ensurePrefs();
    await prefs.setString(_kName, name);
  }

  // Synchronous getters are preserved for existing UI and service callers.
  // The token cache is populated only after secure storage has been read.
  static String? getAccessToken() => _accessToken;
  static String? getRefreshToken() => _refreshToken;
  static String? getRole() => _prefs?.getString(_kRole);
  static String? getUserEmail() => _prefs?.getString(_kEmail);
  static String? getName() => _prefs?.getString(_kName);

  static bool get isLoggedIn {
    final token = _accessToken;
    return token != null && token.isNotEmpty;
  }

  /// Clears the in-memory session first, then attempts to delete all stored
  /// authentication values and non-secret session metadata.
  static Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;

    var secureDeleteFailed = false;
    for (final key in [_kAccess, _kRefresh]) {
      try {
        await _tokenStore.delete(key);
      } catch (_) {
        secureDeleteFailed = true;
      }
    }

    final prefs = await _ensurePrefs();
    for (final key in [_kAccess, _kRefresh, _kRole, _kEmail, _kName]) {
      await prefs.remove(key);
    }

    _initialized = true;
    if (secureDeleteFailed) {
      throw StateError(
        'The local secure session could not be fully deleted.',
      );
    }

    debugPrint('AuthStorage cleared the local session.');
  }

  static Future<void> _deleteSecureTokensBestEffort() async {
    for (final key in [_kAccess, _kRefresh]) {
      try {
        await _tokenStore.delete(key);
      } catch (_) {
        // Do not mask the original persistence error.
      }
    }
  }

  @visibleForTesting
  static void setTokenStoreForTesting(AuthTokenStore tokenStore) {
    _tokenStore = tokenStore;
    _resetStateForTesting();
  }

  @visibleForTesting
  static void resetForTesting() {
    _tokenStore = const _FlutterSecureTokenStore();
    _resetStateForTesting();
  }

  static void _resetStateForTesting() {
    _prefs = null;
    _accessToken = null;
    _refreshToken = null;
    _initialized = false;
    _initFuture = null;
  }
}
