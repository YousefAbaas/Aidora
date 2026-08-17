/// fake_api_service.dart
///
/// Single source of truth for the fake ApiService used across all tests.
/// Matches the EXACT ApiService method signatures including `isRetry`.
///
/// Usage:
///   final fake = FakeApiService(
///     posts: {ApiConstants.login: ApiResponse.success({...}, code: 200)},
///     gets:  {ApiConstants.requestList: ApiResponse.success({...}, code: 200)},
///   );
library;

import 'package:aidora/services/api_service.dart';
import 'package:http/http.dart' as http;

/// A configurable fake implementation of [ApiService].
///
/// Matches the exact method signatures of the real [ApiService] including
/// the `isRetry` parameter that was causing compilation failures.
class FakeApiService implements ApiService {
  final Map<String, ApiResponse> _posts;
  final Map<String, ApiResponse> _gets;
  final Map<String, ApiResponse> _patches;
  final Map<String, ApiResponse> _deletes;

  /// Call counters — useful for assertions like `expect(fake.postCount, 1)`.
  int getCount = 0;
  int postCount = 0;
  int patchCount = 0;
  int deleteCount = 0;

  http.Client? _customClient;

  FakeApiService({
    Map<String, ApiResponse> posts = const {},
    Map<String, ApiResponse> gets = const {},
    Map<String, ApiResponse> patches = const {},
    Map<String, ApiResponse> deletes = const {},
  })  : _posts = posts,
        _gets = gets,
        _patches = patches,
        _deletes = deletes;

  // ── CLIENT MANAGEMENT ─────────────────────────────────────────────────────────
  @override
  set client(http.Client customClient) {
    _customClient = customClient;
  }

  @override
  void resetClient() {
    _customClient = null;
  }

  // ── GET ─────────────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false, // ← required by real ApiService
    Map<String, String>? queryParams,
  }) async {
    getCount++;
    // Build key with optional ?status= filter
    final key = queryParams?.isNotEmpty == true
        ? '$endpoint?status=${queryParams!['status']}'
        : endpoint;
    return _gets[key] ??
        _gets[endpoint] ??
        ApiResponse.error('FakeApi: unmapped GET $endpoint', code: 404);
  }

  // ── POST ─────────────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse> post(
    String endpoint, {
    required Map<String, dynamic> body, // ← required in real ApiService
    bool requiresAuth = false,
    bool isRetry = false, // ← required by real ApiService
    Map<String, String>? headers,
  }) async {
    postCount++;
    return _posts[endpoint] ??
        ApiResponse.error('FakeApi: unmapped POST $endpoint', code: 404);
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse> patch(
    String endpoint, {
    required Map<String, dynamic> body, // ← required in real ApiService
    bool requiresAuth = false,
    bool isRetry = false, // ← required by real ApiService
  }) async {
    patchCount++;
    return _patches[endpoint] ??
        ApiResponse.error('FakeApi: unmapped PATCH $endpoint', code: 404);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  @override
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false, // ← required by real ApiService
  }) async {
    deleteCount++;
    return _deletes[endpoint] ??
        ApiResponse.error('FakeApi: unmapped DELETE $endpoint', code: 404);
  }
}

/// Shorthand constructors for [ApiResponse] — keeps test code concise.
ApiResponse ok(dynamic json, [int code = 200]) =>
    ApiResponse.success(json, code: code);

ApiResponse fail(String message, [int code = 400]) =>
    ApiResponse.error(message, code: code);
