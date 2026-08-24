/// login_screen_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/views/login_screen.dart';

import '../helpers/fixtures.dart';
import '../helpers/fake_api_service.dart';
import 'package:aidora/services/api_service.dart';
Future<FakeApiService> pumpLogin(WidgetTester tester, {
  String? role,
  ApiResponse? loginResp,
}) async {
  final fake = FakeApiService(
    posts: {
      ApiConstants.login:
          loginResp ?? fakeFail('not used', 0),
    },
  );
  AuthService.overrideForTest(fake);
  Get.put(BottomNavController());
  Get.put(SettingsController());
  await tester.pumpWidget(GetMaterialApp(home: LoginScreen(role: role)));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  setUp(() {});
  tearDown(() {
    AuthService.resetOverride();
    Get.reset();
  });

  // ── Rendering ────────────────────────────────────────────────────────────────
  group('LoginScreen — rendering', () {
    testWidgets('shows Aidora title and Login button', (t) async {
      await pumpLogin(t);
      expect(find.text('Aidora'), findsOneWidget);
      expect(find.text('Login'),  findsOneWidget);
    });

    testWidgets('role=volunteer → Volunteer Login subtitle', (t) async {
      await pumpLogin(t, role: 'volunteer');
      expect(find.text('Volunteer Login'), findsOneWidget);
    });

    testWidgets('role=org → Organization Login subtitle', (t) async {
      await pumpLogin(t, role: 'org');
      expect(find.text('Organization Login'), findsOneWidget);
    });

    testWidgets('role=org → no Create Account link', (t) async {
      await pumpLogin(t, role: 'org');
      expect(find.text('Create an Account'),     findsNothing);
      expect(find.text('Register as Volunteer'), findsNothing);
    });

    testWidgets('generic → Create an Account link shown', (t) async {
      await pumpLogin(t);
      expect(find.text('Create an Account'), findsOneWidget);
    });

    testWidgets('role=volunteer → Register as Volunteer link', (t) async {
      await pumpLogin(t, role: 'volunteer');
      expect(find.text('Register as Volunteer'), findsOneWidget);
    });

    testWidgets('two TextFields — email and password', (t) async {
      await pumpLogin(t);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Forgot password link present', (t) async {
      await pumpLogin(t);
      expect(find.text('Forgot password?'), findsOneWidget);
    });
  });

  // ── Form Validation ──────────────────────────────────────────────────────────
  group('LoginScreen — form validation', () {
    testWidgets('empty fields → API never called', (t) async {
      final fake = await pumpLogin(t);
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.postCount, 0);
    });

    testWidgets('only email → API not called', (t) async {
      final fake = await pumpLogin(t);
      await t.enterText(find.byType(TextField).first, 'ahmed@test.com');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.postCount, 0);
    });

    testWidgets('both filled → API called once', (t) async {
      final fake = await pumpLogin(t,
          loginResp: fakeFail('wrong pw', 401));
      await t.enterText(find.byType(TextField).first, 'ahmed@test.com');
      await t.enterText(find.byType(TextField).last,  'password123');
      await t.tap(find.text('Login'));
      await t.pumpAndSettle();
      expect(fake.postCount, 1);
    });
  });

  // ── Password Visibility ──────────────────────────────────────────────────────
  group('LoginScreen — password visibility', () {
    testWidgets('password obscured by default', (t) async {
      await pumpLogin(t);
      final field = t.widget<TextField>(find.byType(TextField).last);
      expect(field.obscureText, isTrue);
    });

    testWidgets('tap visibility icon → text shown', (t) async {
      await pumpLogin(t);
      await t.tap(find.byIcon(Icons.visibility_outlined));
      await t.pumpAndSettle();
      expect(t.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
    });

    testWidgets('tap again → text hidden', (t) async {
      await pumpLogin(t);
      await t.tap(find.byIcon(Icons.visibility_outlined));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.visibility_off_outlined));
      await t.pumpAndSettle();
      expect(t.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
    });
  });

  // ── ApiConstants (pure Dart) ─────────────────────────────────────────────────
  group('ApiConstants — URL construction', () {
    test('orgServices',        () => expect(ApiConstants.orgServices(5),         '/api/requests/5/services/'));
    test('createRequest',      () => expect(ApiConstants.createRequest(3),       '/api/requests/3/createrequest/'));
    test('requestDetails',     () => expect(ApiConstants.requestDetails(42),     '/api/requests/42/details/'));
    test('volunteerQr',        () => expect(ApiConstants.volunteerQr(7),         '/api/auth/volunteers/7/qr/'));
    test('organizationDetail', () => expect(ApiConstants.organizationDetail(9),  '/api/organizations/9/'));
    test('organizationFilter', () => expect(ApiConstants.organizationFilter('Education'), '/api/organizations/filter/Education/'));
  });
}
