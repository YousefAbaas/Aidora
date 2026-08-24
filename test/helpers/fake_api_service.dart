import 'dart:async';

import 'package:aidora/services/api_client.dart';
import 'package:aidora/services/api_service.dart';

ApiResponse ok(
  dynamic json, [
  int code = 200,
]) {
  return ApiResponse.success(
    json,
    code: code,
  );
}

ApiResponse apiFail(
  String message, [
  int code = 400,
]) {
  return ApiResponse.error(
    message,
    code: code,
  );
}

ApiResponse fakeFail(
  String message, [
  int code = 400,
]) {
  return ApiResponse.error(
    message,
    code: code,
  );
}

/// Fake API client used by unit/widget/integration tests.
///
/// Responses are selected by endpoint, allowing tests to run without
/// contacting the real backend.
class FakeApiService implements ApiClient {
  final Map<String, ApiResponse> gets;
  final Map<String, ApiResponse> posts;
  final Map<String, Future<ApiResponse>> getFutures;

  FakeApiService({
    this.gets = const {},
    this.posts = const {},
    this.getFutures = const {},
  });
  int postCount = 0;

  @override
  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false,
  }) async {
    if (getFutures.containsKey(endpoint)) {
      return getFutures[endpoint]!;
    }

    return gets[endpoint] ??
        ApiResponse.error(
          'No fake GET response configured for "$endpoint". '
              'Available fake GETs: ${gets.keys.join(', ')}',
          code: 404,
        );
  }

  @override
  Future<ApiResponse> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    bool isRetry = false,
  }) async {
    postCount++;

    return posts[endpoint] ??
        ApiResponse.error(
          'No fake POST response configured for $endpoint',
          code: 404,
        );
  }

  @override
  Future<ApiResponse> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    bool isRetry = false,
  }) async {
    return ApiResponse.error(
      'Fake PATCH response not configured for $endpoint',
      code: 404,
    );
  }

  @override
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false,
  }) async {
    return ApiResponse.error(
      'Fake DELETE response not configured for $endpoint',
      code: 404,
    );
  }
}
