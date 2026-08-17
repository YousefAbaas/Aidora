import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_storage.dart';
import 'token_manager.dart';
import 'web_http_stub.dart' if (dart.library.html) 'web_http.dart';

/// Central HTTP client — GET · POST · PATCH with full token lifecycle.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
  static const _timeout = Duration(seconds: 25);

  /// Persistent HTTP client — reuses TCP connections for better performance.
  http.Client _client = http.Client();

  /// Permet تعيين client وهمي (MockClient) أثناء تشغيل الـ Unit/Widget Tests
  @visibleForTesting
  set client(http.Client customClient) {
    _client = customClient;
  }

  /// إعادة تعيين الـ client إلى الافتراضي بعد الانتهاء من الاختبارات
  @visibleForTesting
  void resetClient() {
    _client = http.Client();
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (ApiConstants.baseUrl.contains('ngrok')) {
      h['ngrok-skip-browser-warning'] = 'true';
      h['User-Agent'] = 'AidoraApp/1.0';
    }

    if (auth) {
      final token = await TokenManager.instance.getValidAccessToken();
      if (token != null && token.isNotEmpty) {
        h['Authorization'] = 'Bearer $token';
      } else {
        debugPrint('⚠️  No valid token available');
      }
    }
    return h;
  }

  // ── GET ─────────────────────────────────────────────────────────────────────
  Future<ApiResponse> get(String endpoint,
      {bool requiresAuth = false, bool isRetry = false}) async {
    final url = '${ApiConstants.baseUrl}$endpoint';
    debugPrint('🌐 GET $url');
    try {
      if (kIsWeb) {
        final webRes = await webGet(url, await _headers(auth: requiresAuth));
        if (webRes == null)
          return ApiResponse.error('Web HTTP unavailable', code: 0);
        final r = http.Response(webRes.body, webRes.statusCode);
        if (_needsRefresh(r.statusCode) && !isRetry && requiresAuth) {
          final ok = await TokenManager.instance.forceRefresh();
          if (ok) return get(endpoint, requiresAuth: true, isRetry: true);
          _expiredSession();
        }
        return _parse(r);
      }
      final res = await _client
          .get(Uri.parse(url), headers: await _headers(auth: requiresAuth))
          .timeout(_timeout);
      if (_needsRefresh(res.statusCode) && !isRetry && requiresAuth) {
        final ok = await TokenManager.instance.forceRefresh();
        if (ok) return get(endpoint, requiresAuth: true, isRetry: true);
        _expiredSession();
      }
      return _parse(res);
    } catch (e) {
      return _netErr(e, url);
    }
  }

  // ── POST ─────────────────────────────────────────────────────────────────────
  Future<ApiResponse> post(String endpoint,
      {required Map<String, dynamic> body,
      bool requiresAuth = false,
      bool isRetry = false}) async {
    final url = '${ApiConstants.baseUrl}$endpoint';
    debugPrint('🌐 POST $url');
    try {
      if (kIsWeb) {
        final webRes =
            await webPost(url, body, await _headers(auth: requiresAuth));
        if (webRes == null)
          return ApiResponse.error('Web HTTP unavailable', code: 0);
        final r = http.Response(webRes.body, webRes.statusCode);
        if (_needsRefresh(r.statusCode) && !isRetry && requiresAuth) {
          final ok = await TokenManager.instance.forceRefresh();
          if (ok)
            return post(endpoint,
                body: body, requiresAuth: true, isRetry: true);
          _expiredSession();
        }
        return _parse(r);
      }
      final res = await _client
          .post(Uri.parse(url),
              headers: await _headers(auth: requiresAuth),
              body: jsonEncode(body))
          .timeout(_timeout);
      if (_needsRefresh(res.statusCode) && !isRetry && requiresAuth) {
        final ok = await TokenManager.instance.forceRefresh();
        if (ok)
          return post(endpoint, body: body, requiresAuth: true, isRetry: true);
        _expiredSession();
      }
      return _parse(res);
    } catch (e) {
      return _netErr(e, url);
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────────
  Future<ApiResponse> patch(String endpoint,
      {required Map<String, dynamic> body,
      bool requiresAuth = false,
      bool isRetry = false}) async {
    final url = '${ApiConstants.baseUrl}$endpoint';
    debugPrint('🌐 PATCH $url');
    try {
      if (kIsWeb) {
        final webRes =
            await webPatch(url, body, await _headers(auth: requiresAuth));
        if (webRes == null)
          return ApiResponse.error('Web HTTP unavailable', code: 0);
        final r = http.Response(webRes.body, webRes.statusCode);
        if (_needsRefresh(r.statusCode) && !isRetry && requiresAuth) {
          final ok = await TokenManager.instance.forceRefresh();
          if (ok)
            return patch(endpoint,
                body: body, requiresAuth: true, isRetry: true);
          _expiredSession();
        }
        return _parse(r);
      }
      final res = await _client
          .patch(Uri.parse(url),
              headers: await _headers(auth: requiresAuth),
              body: jsonEncode(body))
          .timeout(_timeout);
      if (_needsRefresh(res.statusCode) && !isRetry && requiresAuth) {
        final ok = await TokenManager.instance.forceRefresh();
        if (ok)
          return patch(endpoint, body: body, requiresAuth: true, isRetry: true);
        _expiredSession();
      }
      return _parse(res);
    } catch (e) {
      return _netErr(e, url);
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<ApiResponse> delete(String endpoint,
      {bool requiresAuth = false, bool isRetry = false}) async {
    final url = '${ApiConstants.baseUrl}$endpoint';
    debugPrint('🌐 DELETE $url');
    try {
      if (kIsWeb) {
        final webRes = await webDelete(url, await _headers(auth: requiresAuth));
        if (webRes == null)
          return ApiResponse.error('Web HTTP unavailable', code: 0);
        final r = http.Response(webRes.body, webRes.statusCode);
        if (_needsRefresh(r.statusCode) && !isRetry && requiresAuth) {
          final ok = await TokenManager.instance.forceRefresh();
          if (ok) return delete(endpoint, requiresAuth: true, isRetry: true);
          _expiredSession();
        }
        return _parse(r);
      }
      final res = await _client
          .delete(Uri.parse(url), headers: await _headers(auth: requiresAuth))
          .timeout(_timeout);
      if (_needsRefresh(res.statusCode) && !isRetry && requiresAuth) {
        final ok = await TokenManager.instance.forceRefresh();
        if (ok) return delete(endpoint, requiresAuth: true, isRetry: true);
        _expiredSession();
      }
      return _parse(res);
    } catch (e) {
      return _netErr(e, url);
    }
  }

  bool _needsRefresh(int code) => code == 401 || code == 403;

  void _expiredSession() {
    AuthStorage.clear();
    Future.microtask(() => Get.offAllNamed('/selection'));
  }

  ApiResponse _parse(http.Response r) {
    final bodyPreview =
        r.body.length > 200 ? r.body.substring(0, 200) + '…' : r.body;
    debugPrint('   ← ${r.statusCode}  $bodyPreview');

    final trimmed = r.body.trimLeft();
    final isHtml = trimmed.startsWith('<!DOCTYPE') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<!doctype');
    if (isHtml) {
      final msgs = <int, String>{
        400: 'Bad request (400).',
        401: 'Unauthorized (401). Please login again.',
        403: 'Access denied (403).',
        404: 'This feature is not yet available on the server (404).',
        405: 'Method not allowed (405).',
        500: 'Server error (500). Try again later.',
        502: 'Server unreachable (502).',
        503: 'Service unavailable (503).',
      };
      final friendly = msgs[r.statusCode] ??
          'Server error (${r.statusCode}). Please try again.';
      return ApiResponse.error(friendly, code: r.statusCode);
    }

    if (r.body.trim().isEmpty) {
      return r.statusCode >= 200 && r.statusCode < 300
          ? ApiResponse.success(<String, dynamic>{}, code: r.statusCode)
          : ApiResponse.error('Empty response (${r.statusCode}).',
              code: r.statusCode);
    }

    dynamic d;
    try {
      d = jsonDecode(r.body);
    } catch (e) {
      debugPrint('   ⚠️  jsonDecode failed: $e');
      d = {'raw': r.body};
    }
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return ApiResponse.success(d, code: r.statusCode);
    }
    return ApiResponse.error(_djErr(d, r.statusCode), code: r.statusCode);
  }

  ApiResponse _netErr(Object e, String url) {
    final s = e.toString();
    debugPrint('❌ [$url] $s');
    if (kIsWeb && s.contains('Failed to fetch')) {
      return ApiResponse.error(
          'CORS Error — add django-cors-headers.\n'
          'pip install django-cors-headers\n'
          'CORS_ALLOW_ALL_ORIGINS = True',
          code: 0);
    }
    if (s.contains('SocketException') ||
        s.contains('Connection refused') ||
        s.contains('Failed host lookup')) {
      return ApiResponse.error(
          'Cannot reach server.\nRun: python manage.py runserver\n'
          'URL: ${ApiConstants.baseUrl}',
          code: 0);
    }
    if (e is TimeoutException) {
      return ApiResponse.error('Timeout (${_timeout.inSeconds}s).', code: 408);
    }
    return ApiResponse.error('Network error: $s', code: -1);
  }

  String _djErr(dynamic d, int code) {
    if (d is Map) {
      if (d.containsKey('non_field_errors')) {
        final v = d['non_field_errors'];
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
      for (final k in ['detail', 'error', 'message']) {
        if (d.containsKey(k)) return d[k].toString();
      }
      final parts = <String>[];
      d.forEach((k, v) => parts.add(v is List ? '$k: ${v.first}' : '$k: $v'));
      if (parts.isNotEmpty) return parts.join('\n');
    }
    if (d is String && d.isNotEmpty) return d;
    return {
          400: 'Invalid data.',
          401: 'Session expired. Please log in again.',
          403: 'Session expired. Please log in again.',
          404: 'Not found.',
          405: 'Method not allowed.',
          500: 'Server error. Try again later.',
        }[code] ??
        'Request failed ($code).';
  }
}

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int statusCode;
  const ApiResponse._(
      {required this.isSuccess,
      required this.statusCode,
      this.data,
      this.errorMessage});
  factory ApiResponse.success(dynamic d, {required int code}) =>
      ApiResponse._(isSuccess: true, statusCode: code, data: d);
  factory ApiResponse.error(String m, {required int code}) =>
      ApiResponse._(isSuccess: false, statusCode: code, errorMessage: m);
}
