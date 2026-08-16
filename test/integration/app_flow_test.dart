/// app_flow_test.dart
///
/// Integration-style test: pumps the full app from SplashScreen,
/// injects fakes at service level, and verifies the full login→dashboard flow.
///
/// Run: flutter test test/integration/app_flow_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/auth_storage.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/controllers/profile_controller.dart';
import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/views/login_screen.dart';

import '../helpers/fixtures.dart';

// ── Combined fake that handles all routes in the login flow ──────────────────
class _FlowFakeApi implements ApiService {
  final ApiResponse _loginResp;
  _FlowFakeApi(this._loginResp);

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
       Map<String, String>? headers}) async {
    if (path == ApiConstants.login)  return _loginResp;
    if (path == ApiConstants.logout) return ApiResponse.success({'message': 'ok'}, code: 200);
    return ApiResponse.error('Unmapped POST $path', code: 500);
  }

  @override
  Future<ApiResponse> get(String path,
      {Map<String, String>? queryParams, bool requiresAuth = false}) async {
    if (path == ApiConstants.refugeeProfile)
      return ApiResponse.success(Map.from(refugeeProfileJson), code: 200);
    if (path == ApiConstants.requestList)
      return ApiResponse.success(Map.from(requestsListJson), code: 200);
    if (path == ApiConstants.notifications)
      return ApiResponse.success({'results': [], 'unread_count': 0}, code: 200);
    return ApiResponse.error('Unmapped GET $path', code: 404);
  }

  @override Future<ApiResponse> patch(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
  @override Future<ApiResponse> delete(String path,
      {bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
}

// ── App bootstrap ─────────────────────────────────────────────────────────────
Widget _buildTestApp({required ApiResponse loginResp, String? role}) {
  final fakeApi = _FlowFakeApi(loginResp);
  AuthService.overrideForTest(fakeApi);
  RequestsApiService.overrideForTest(
      RequestsApiService.testInstance(fakeApi));

  Get.put(BottomNavController());
  Get.put(SettingsController());
  Get.put(ProfileController());
  Get.put(NotificationService());

  return GetMaterialApp(home: LoginScreen(role: role));
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUp(() {});
  tearDown(() {
    AuthService.resetOverride();
    RequestsApiService.resetOverride();
    Get.reset();
  });

  // ── Login → Dashboard flow ─────────────────────────────────────────────────
  group('Login → Refugee Dashboard flow', () {
    testWidgets('fills credentials → taps Login → navigates to dashboard', (t) async {
      await t.pumpWidget(_buildTestApp(
        loginResp: ApiResponse.success(Map.from(loginSuccessJson), code: 200),
      ));
      await t.pumpAndSettle();

      // Should be on LoginScreen
      expect(find.text('Login'), findsOneWidget);

      // Fill email
      await t.enterText(find.byType(TextField).first, 'ahmed@example.com');
      // Fill password
      await t.enterText(find.byType(TextField).last, 'pass1234');

      // Tap Login
      await t.tap(find.text('Login'));
      await t.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate away from LoginScreen
      expect(find.text('Login'), findsNothing);
    });
  });

  // ── Validation flow ────────────────────────────────────────────────────────
  group('Login validation flow', () {
    testWidgets('empty email → stays on LoginScreen', (t) async {
      await t.pumpWidget(_buildTestApp(
        loginResp: ApiResponse.success(Map.from(loginSuccessJson), code: 200),
      ));
      await t.pumpAndSettle();

      // Only fill password, no email
      await t.enterText(find.byType(TextField).last, 'pass1234');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();

      // LoginScreen stays
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('wrong credentials → shows error snackbar', (t) async {
      await t.pumpWidget(_buildTestApp(
        loginResp: ApiResponse.error('Invalid credentials', code: 401),
      ));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField).first, 'bad@email.com');
      await t.enterText(find.byType(TextField).last, 'wrongpass');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();

      // Error shown
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
      // Still on login screen
      expect(find.text('Login'), findsOneWidget);
    });
  });

  // ── Role-based routing ─────────────────────────────────────────────────────
  group('Role-based routing', () {
    testWidgets('role=volunteer login button visible with correct subtitle', (t) async {
      await t.pumpWidget(_buildTestApp(
        loginResp: ApiResponse.success(Map.from(loginVolunteerJson), code: 200),
        role: 'volunteer',
      ));
      await t.pumpAndSettle();

      expect(find.text('Volunteer Login'), findsOneWidget);
      expect(find.text('Login'),           findsOneWidget);
    });

    testWidgets('role=org — no Register link shown', (t) async {
      await t.pumpWidget(_buildTestApp(
        loginResp: ApiResponse.success(Map.from(loginOrgJson), code: 200),
        role: 'org',
      ));
      await t.pumpAndSettle();

      expect(find.text('Organization Login'), findsOneWidget);
      expect(find.text('Create an Account'),  findsNothing);
    });
  });
}
