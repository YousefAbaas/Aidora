import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'auth_storage.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class TokenManager {
  TokenManager._();
  static final TokenManager instance = TokenManager._();

  // Pending refresh â€” prevent duplicate HTTP calls
  Future<bool>? _pendingRefresh;

  /// Returns a valid access token, refreshing if needed.
  /// Returns null if refresh fails and token is expired.
  Future<String?> getValidAccessToken() async {
    final token = AuthStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('ðŸ”‘ TokenManager: no stored access token');
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
      debugPrint('âŒ No refresh token stored');
      return false;
    }

    final url = '${ApiConstants.baseUrl}${ApiConstants.tokenRefresh}';
    debugPrint('ðŸ“¡ POST $url');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('   â† ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess = body['access'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await AuthStorage.updateAccessToken(newAccess);
          final left = _secondsLeft(newAccess);
          debugPrint('âœ… New access token valid for ${left}s');
          return true;
        }
        debugPrint('âŒ Refresh response missing access field');
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
