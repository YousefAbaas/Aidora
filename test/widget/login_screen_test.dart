/// login_screen_test.dart
///
/// Widget tests for LoginScreen.
/// • Field rendering per role
/// • Validation (empty fields blocked)
/// • Password visibility toggle
/// • API URL construction (pure Dart, no widgets needed)
///
/// Run: flutter test test/widget/login_screen_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/views/login_screen.dart';

// ── Minimal fake API ──────────────────────────────────────────────────────────
class _FakeApi implements ApiService {
  int callCount = 0;
  final ApiResponse _loginResp;
  _FakeApi(this._loginResp);

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
       Map<String, String>? headers}) async {
    if (path == ApiConstants.login) { callCount++; return _loginResp; }
    return ApiResponse.error('Unmapped POST $path', code: 500);
  }
  @override Future<ApiResponse> get(String path,
      {Map<String, String>? queryParams, bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
  @override Future<ApiResponse> patch(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
  @override Future<ApiResponse> delete(String path,
      {bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
}

// ── Helper: pump a LoginScreen ────────────────────────────────────────────────
Future<_FakeApi> pumpLogin(WidgetTester tester, {
  String? role,
  ApiResponse? loginResp,
}) async {
  final fake = _FakeApi(
    loginResp ?? ApiResponse.error('not used', code: 0),
  );
  AuthService.overrideForTest(fake);

  Get.put(BottomNavController());
  Get.put(SettingsController());

  await tester.pumpWidget(GetMaterialApp(home: LoginScreen(role: role)));
  await tester.pumpAndSettle();
  return fake;
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUp(() { Get.reset(); AuthService.resetOverride(); });
  tearDown(() { Get.reset(); AuthService.resetOverride(); });

  // ── Rendering ──────────────────────────────────────────────────────────────
  group('LoginScreen — rendering', () {
    testWidgets('generic — shows Login button and Aidora title', (t) async {
      await pumpLogin(t);
      expect(find.text('Aidora'), findsOneWidget);
      expect(find.text('Login'),  findsOneWidget);
    });

    testWidgets('role=volunteer — subtitle Volunteer Login', (t) async {
      await pumpLogin(t, role: 'volunteer');
      expect(find.text('Volunteer Login'), findsOneWidget);
    });

    testWidgets('role=org — subtitle Organization Login', (t) async {
      await pumpLogin(t, role: 'org');
      expect(find.text('Organization Login'), findsOneWidget);
    });

    testWidgets('role=org — no Create Account link', (t) async {
      await pumpLogin(t, role: 'org');
      expect(find.text('Create an Account'),    findsNothing);
      expect(find.text('Register as Volunteer'), findsNothing);
    });

    testWidgets('generic — shows Create an Account link', (t) async {
      await pumpLogin(t);
      expect(find.text('Create an Account'), findsOneWidget);
    });

    testWidgets('role=volunteer — shows Register as Volunteer link', (t) async {
      await pumpLogin(t, role: 'volunteer');
      expect(find.text('Register as Volunteer'), findsOneWidget);
    });

    testWidgets('two TextFields present (email + password)', (t) async {
      await pumpLogin(t);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Forgot password link present', (t) async {
      await pumpLogin(t);
      expect(find.text('Forgot password?'), findsOneWidget);
    });
  });

  // ── Form validation ────────────────────────────────────────────────────────
  group('LoginScreen — form validation', () {
    testWidgets('empty fields → API never called', (t) async {
      final fake = await pumpLogin(t);
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.callCount, 0);
    });

    testWidgets('only email filled → API never called', (t) async {
      final fake = await pumpLogin(t);
      await t.enterText(find.byType(TextField).first, 'ahmed@test.com');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.callCount, 0);
    });

    testWidgets('both fields filled → API called once', (t) async {
      final fake = await pumpLogin(t,
        loginResp: ApiResponse.error('wrong pw', code: 401));
      await t.enterText(find.byType(TextField).first, 'ahmed@test.com');
      await t.enterText(find.byType(TextField).last,  'password123');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.callCount, 1);
    });
  });

  // ── Password visibility ────────────────────────────────────────────────────
  group('LoginScreen — password visibility toggle', () {
    testWidgets('password is obscured by default', (t) async {
      await pumpLogin(t);
      final pwField = t.widget<TextField>(find.byType(TextField).last);
      expect(pwField.obscureText, isTrue);
    });

    testWidgets('tap visibility icon → text shown', (t) async {
      await pumpLogin(t);
      await t.tap(find.byIcon(Icons.visibility_outlined));
      await t.pumpAndSettle();
      final pwField = t.widget<TextField>(find.byType(TextField).last);
      expect(pwField.obscureText, isFalse);
    });

    testWidgets('tap again → text hidden again', (t) async {
      await pumpLogin(t);
      await t.tap(find.byIcon(Icons.visibility_outlined));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.visibility_off_outlined));
      await t.pumpAndSettle();
      final pwField = t.widget<TextField>(find.byType(TextField).last);
      expect(pwField.obscureText, isTrue);
    });
  });

  // ── ApiConstants URL construction (pure Dart — no widget pump) ─────────────
  group('ApiConstants — URL construction', () {
    test('orgServices', () =>
        expect(ApiConstants.orgServices(5), '/api/requests/5/services/'));

    test('createRequest', () =>
        expect(ApiConstants.createRequest(3), '/api/requests/3/createrequest/'));

    test('requestDetails', () =>
        expect(ApiConstants.requestDetails(42), '/api/requests/42/details/'));

    test('volunteerQr', () =>
        expect(ApiConstants.volunteerQr(7), '/api/auth/volunteers/7/qr/'));

    test('organizationDetail', () =>
        expect(ApiConstants.organizationDetail(9), '/api/organizations/9/'));

    test('organizationFilter', () =>
        expect(ApiConstants.organizationFilter('Education'),
               '/api/organizations/filter/Education/'));
  });
}
