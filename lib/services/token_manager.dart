import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, visibleForTesting;
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'auth_storage.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// TokenManager
///
/// The Django backend uses short-lived access tokens and long-lived refresh
/// tokens. When the access token expires, we POST to /api/auth/token/refresh/
/// with the refresh token to get a new access/refresh token pair. The backend
/// rotates refresh tokens and blacklists the previous token, so both returned
/// values must be persisted together.
///
/// This class:
///  1. Decodes the JWT exp to know exactly when the access token expires
///  2. Proactively refreshes when < 120s remain (prevents mid-request expiry)
///  3. On 401/403: force-refresh immediately and retry
///  4. Deduplicates concurrent refresh calls (only one HTTP request at a time)
///  5. Persists both tokens after rotation; clears storage on invalid responses
///  6. On total session expiry (refresh also expired): clears storage
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class TokenManager {
  TokenManager._() : _client = http.Client();

  @visibleForTesting
  TokenManager.forTesting(http.Client client) : _client = client;

  static final TokenManager instance = TokenManager._();

  final http.Client _client;

  // Pending refresh â€” prevent duplicate HTTP calls
  Future<bool>? _pendingRefresh;

  /// Returns a valid access token, refreshing if needed.
  /// Returns null if refresh fails and token is expired.
  Future<String?> getValidAccessToken() async {
    final token = AuthStorage.getAccessToken();
    final refreshToken = AuthStorage.getRefreshToken();
    if (token == null ||
        token.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      debugPrint('ðŸ”‘ TokenManager: incomplete session; clearing local credentials');
      await AuthStorage.clear();
      return null;
    }

    final secsLeft = _secondsLeft(token);
    debugPrint('â± Access token expires in ${secsLeft}s');

    // Proactive refresh when close to expiry
    if (secsLeft < 120) {
      debugPrint('ðŸ”„ Proactive refresh (${secsLeft}s left)...');
      final ok = await _dedupedRefresh();
      if (!ok && secsLeft <= 0) {
        debugPrint('âŒ Token expired, refresh failed â€” need re-login');
        return null;
      }
    }

    return AuthStorage.getAccessToken();
  }

  /// Force-refresh immediately (called after 401 or 403 response).
  Future<bool> forceRefresh() {
    debugPrint('ðŸ”„ Force-refresh triggered by 401/403');
    return _dedupedRefresh();
  }

  // â”€â”€ Internal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<bool> _dedupedRefresh() {
    _pendingRefresh ??= _doRefresh().whenComplete(() {
      _pendingRefresh = null;
    });
    return _pendingRefresh!;
  }

  Future<bool> _doRefresh() async {
    final refreshToken = AuthStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('âŒ No refresh token stored; clearing incomplete session');
      await AuthStorage.clear();
      return false;
    }

    final url = '${ApiConstants.baseUrl}${ApiConstants.tokenRefresh}';
    debugPrint('ðŸ“¡ POST $url');

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('   <- refresh status ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          debugPrint('âŒ Refresh response contained invalid JSON');
          await AuthStorage.clear();
          return false;
        }
        if (decoded is! Map<String, dynamic>) {
          debugPrint('âŒ Refresh response was not a JSON object');
          await AuthStorage.clear();
          return false;
        }

        final newAccess = decoded['access'];
        final newRefresh = decoded['refresh'];
        if (newAccess is String &&
            newAccess.isNotEmpty &&
            newRefresh is String &&
            newRefresh.isNotEmpty) {
          await AuthStorage.updateSessionTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          final left = _secondsLeft(newAccess);
          debugPrint('âœ… Rotated session tokens; access valid for ${left}s');
          return true;
        }

        // The backend is configured to rotate refresh tokens and blacklist
        // the previous one. A partial response cannot safely keep the old
        // refresh token, so invalidate the local session.
        debugPrint('âŒ Refresh response missing access or rotated refresh token');
        await AuthStorage.clear();
        return false;
      }

      // 401 means refresh token is itself expired â€” session fully dead
      if (response.statusCode == 401) {
        debugPrint('âŒ Refresh token expired â€” clearing session');
        await AuthStorage.clear();
      }

      return false;
    } catch (e) {
      debugPrint('âŒ Refresh HTTP error: $e');
      return false;
    }
  }

  // â”€â”€ Decode JWT exp â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _secondsLeft(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 0;
      var b64 = parts[1];
      // Pad base64
      b64 = b64.padRight(b64.length + (4 - b64.length % 4) % 4, '=');
      final payload = jsonDecode(utf8.decode(base64Url.decode(b64)))
          as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return 9999;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp - now;
    } catch (e) {
      debugPrint('âš ï¸ JWT decode error: $e');
      return 0;
    }
  }
}
