import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'auth_storage.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TokenManager
///
/// The Django backend uses short-lived access tokens and long-lived refresh
/// tokens. When the access token expires, we POST to /api/auth/token/refresh/
/// with the refresh token to get a new access token.
///
/// This class:
///  1. Decodes the JWT exp to know exactly when the access token expires
///  2. Proactively refreshes when < 120s remain (prevents mid-request expiry)
///  3. On 401/403: force-refresh immediately and retry
///  4. Deduplicates concurrent refresh calls (only one HTTP request at a time)
///  5. On total session expiry (refresh also expired): clears storage
/// ─────────────────────────────────────────────────────────────────────────────
class TokenManager {
  TokenManager._();
  static final TokenManager instance = TokenManager._();

  // Pending refresh — prevent duplicate HTTP calls
  Future<bool>? _pendingRefresh;

  /// Returns a valid access token, refreshing if needed.
  /// Returns null if refresh fails and token is expired.
  Future<String?> getValidAccessToken() async {
    final token = AuthStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('🔑 TokenManager: no stored access token');
      return null;
    }

    final secsLeft = _secondsLeft(token);
    debugPrint('⏱ Access token expires in ${secsLeft}s');

    // Proactive refresh when close to expiry
    if (secsLeft < 120) {
      debugPrint('🔄 Proactive refresh (${secsLeft}s left)...');
      final ok = await _dedupedRefresh();
      if (!ok && secsLeft <= 0) {
        debugPrint('❌ Token expired, refresh failed — need re-login');
        return null;
      }
    }

    return AuthStorage.getAccessToken();
  }

  /// Force-refresh immediately (called after 401 or 403 response).
  Future<bool> forceRefresh() {
    debugPrint('🔄 Force-refresh triggered by 401/403');
    return _dedupedRefresh();
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  Future<bool> _dedupedRefresh() {
    _pendingRefresh ??= _doRefresh().whenComplete(() {
      _pendingRefresh = null;
    });
    return _pendingRefresh!;
  }

  Future<bool> _doRefresh() async {
    final refreshToken = AuthStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('❌ No refresh token stored');
      return false;
    }

    final url = '${ApiConstants.baseUrl}${ApiConstants.tokenRefresh}';
    debugPrint('📡 POST $url');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept':       'application/json',
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('   ← ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final body      = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess = body['access'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await AuthStorage.updateAccessToken(newAccess);
          final left = _secondsLeft(newAccess);
          debugPrint('✅ New access token valid for ${left}s');
          return true;
        }
        debugPrint('❌ Refresh response missing access field');
        return false;
      }

      // 401 means refresh token is itself expired — session fully dead
      if (response.statusCode == 401) {
        debugPrint('❌ Refresh token expired — clearing session');
        await AuthStorage.clear();
      }

      return false;
    } catch (e) {
      debugPrint('❌ Refresh HTTP error: $e');
      return false;
    }
  }

  // ── Decode JWT exp ─────────────────────────────────────────────────────────
  int _secondsLeft(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 0;
      var b64 = parts[1];
      // Pad base64
      b64 = b64.padRight(b64.length + (4 - b64.length % 4) % 4, '=');
      final payload = jsonDecode(utf8.decode(base64Url.decode(b64)))
          as Map<String, dynamic>;
      final exp  = payload['exp'] as int?;
      if (exp == null) return 9999;
      final now  = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp - now;
    } catch (e) {
      debugPrint('⚠️ JWT decode error: $e');
      return 0;
    }
  }
}
