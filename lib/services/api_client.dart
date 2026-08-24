import 'api_service.dart';

abstract interface class ApiClient {
  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false,
  });

  Future<ApiResponse> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    bool isRetry = false,
  });

  Future<ApiResponse> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
    bool isRetry = false,
  });

  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
    bool isRetry = false,
  });
}
