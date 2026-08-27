library;

import 'dart:io';

import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/controllers/profile_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/services/organization_service.dart';
import 'package:aidora/services/profile_api_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide fail;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_service.dart';
import '../helpers/fixtures.dart';

class TestHttpOverrides extends HttpOverrides {}

Widget _buildApp({
  required dynamic loginResp,
  String? role,
}) {
  Get.reset();

  final fakeApi = FakeApiService(
    posts: {
      ApiConstants.login: loginResp,
    },
    gets: {
      ApiConstants.refugeeProfile: ok(
        Map<String, dynamic>.from(refugeeProfileJson),
      ),
      ApiConstants.requestList: ok(
        Map<String, dynamic>.from(requestsListJson),
      ),
      ApiConstants.notifications: ok(
        <String, dynamic>{
          'results': <dynamic>[],
          'unread_count': 0,
        },
      ),
      ApiConstants.organizationCards: ok(
        Map<String, dynamic>.from(orgCardsJson),
      ),
    },
  );

  // ---------------------------------------------------------------------------
  // IMPORTANT:
  //
  // The integration test must NEVER access the real backend/ngrok server.
  // Every service used by the login/navigation flow receives the fake API.
  // ---------------------------------------------------------------------------

  AuthService.overrideForTest(fakeApi);

  RequestsApiService.overrideForTest(
    RequestsApiService.testInstance(fakeApi),
  );

  OrganizationService.overrideForTest(
    OrganizationService.testInstance(fakeApi),
  );

  ProfileApiService.overrideForTest(
    ProfileApiService.testInstance(fakeApi),
  );

  return GetMaterialApp(
    home: Builder(
      builder: (context) {
        Get.put(BottomNavController());
        Get.put(SettingsController());
        Get.put(ProfileController());
        Get.put(NotificationService());
        Get.put(FormController());

        return LoginScreen(
          role: role,
        );
      },
    ),
  );
}

/// Safely disposes the Flutter test application and GetX state.
///
/// IMPORTANT:
/// Flutter widgets must be removed from the widget tree BEFORE calling
/// Get.reset(). Otherwise GetX controllers/overlays can be disposed while
/// Flutter is still finalizing their widgets, which may leave an active
/// AnimationController/Ticker behind.
///
/// We intentionally avoid pumpAndSettle() here because an external or
/// continuously ticking animation can make pumpAndSettle wait indefinitely.
Future<void> _cleanupTestApp(WidgetTester tester) async {
  debugPrint('🧹 TEST CLEANUP START');

  // -------------------------------------------------------------------------
  // 1. Close GetX overlays first.
  // -------------------------------------------------------------------------

  try {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  } catch (_) {
    // Overlay may already be unavailable.
  }

  try {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  } catch (_) {
    // Dialog may already be disposed.
  }

  // -------------------------------------------------------------------------
  // 2. Allow OverlayEntry removal / Snackbar animation to finish.
  //
  // IMPORTANT:
  // Do NOT call Get.delete(), Get.deleteAll(), or Get.reset() here.
  // The Flutter widget tree is still alive at this point.
  // -------------------------------------------------------------------------

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Drain any remaining scheduled overlay frames.
  await tester.pumpAndSettle(
    const Duration(milliseconds: 50),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 2),
  );

  // -------------------------------------------------------------------------
  // 3. Reset only service overrides.
  //
  // These are static test dependencies and are safe to reset while the
  // widget tree is still mounted.
  // -------------------------------------------------------------------------

  ProfileApiService.resetOverride();
  OrganizationService.resetOverride();
  AuthService.resetOverride();
  RequestsApiService.resetOverride();

  debugPrint('🧹 TEST CLEANUP COMPLETE');
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = TestHttpOverrides();

  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    // -------------------------------------------------------------------------
    // IMPORTANT:
    //
    // Cleanup is handled centrally here.
    //
    // Individual tests MUST NOT call:
    //
    //   Get.reset()
    //   Get.deleteAll()
    //   resetOverride()
    //
    // because doing that while their widget tree is still mounted can create
    // Overlay/Ticker disposal races.
    // -------------------------------------------------------------------------

    debugPrint('🧹 TEST TEARDOWN START');

    // The test framework does not expose WidgetTester directly inside a
    // normal tearDown callback, therefore all widget-specific cleanup is
    // performed by each test through _cleanupTestApp().
    //
    // The following is intentionally kept as a final safety net for GetX.
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
    } catch (_) {}

    ProfileApiService.resetOverride();
    OrganizationService.resetOverride();
    AuthService.resetOverride();
    RequestsApiService.resetOverride();

    try {
      Get.reset();
    } catch (_) {}

    debugPrint('🧹 TEST TEARDOWN COMPLETE');
  });

  group('Login → navigate flow', () {
    // =========================================================================
    // SUCCESSFUL LOGIN
    // =========================================================================

    testWidgets(
      'successful login navigates away from LoginScreen',
          (t) async {
        await t.pumpWidget(
          _buildApp(
            loginResp: ok(
              Map<String, dynamic>.from(loginSuccessJson),
            ),
          ),
        );

        await t.pumpAndSettle();

        // ---------------------------------------------------------------------
        // Verify initial LoginScreen
        // ---------------------------------------------------------------------

        expect(
          find.byType(TextField),
          findsNWidgets(2),
        );

        final emailField = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                'e.g. name@email.com';
          },
        );

        final passwordField = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                '••••••••';
          },
        );

        expect(
          emailField,
          findsOneWidget,
        );

        expect(
          passwordField,
          findsOneWidget,
        );

        // ---------------------------------------------------------------------
        // Enter credentials
        // ---------------------------------------------------------------------

        await t.enterText(
          emailField,
          'ahmed@example.com',
        );

        await t.enterText(
          passwordField,
          'pass1234',
        );

        final loginButton = find.widgetWithText(
          ElevatedButton,
          'Login',
        );

        expect(
          loginButton,
          findsOneWidget,
        );

        // ---------------------------------------------------------------------
        // Tap Login
        // ---------------------------------------------------------------------

        await t.tap(loginButton);

        await t.pump();

        // ---------------------------------------------------------------------
        // Wait for LoginScreen to disappear.
        //
        // We wait for the actual UI condition instead of blindly sleeping.
        // ---------------------------------------------------------------------

        const timeout = Duration(seconds: 5);
        const interval = Duration(milliseconds: 50);

        var elapsed = Duration.zero;

        while (
        find
            .widgetWithText(
          ElevatedButton,
          'Login',
        )
            .evaluate()
            .isNotEmpty &&
            elapsed < timeout) {
          await t.pump(interval);

          elapsed += interval;
        }

        // ---------------------------------------------------------------------
        // Diagnostics
        // ---------------------------------------------------------------------

        debugPrint('🧪 AFTER LOGIN');

        final remainingLoginButtons = find.widgetWithText(
          ElevatedButton,
          'Login',
        );

        final remainingEmailFields = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                'e.g. name@email.com';
          },
        );

        final remainingPasswordFields = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                '••••••••';
          },
        );

        final remainingTextFields = find.byType(
          TextField,
        );

        debugPrint(
          '🧪 Remaining Login buttons: '
              '${remainingLoginButtons.evaluate().length}',
        );

        debugPrint(
          '🧪 Remaining email fields: '
              '${remainingEmailFields.evaluate().length}',
        );

        debugPrint(
          '🧪 Remaining password fields: '
              '${remainingPasswordFields.evaluate().length}',
        );

        debugPrint(
          '🧪 TextFields currently in tree: '
              '${remainingTextFields.evaluate().length}',
        );

        // ---------------------------------------------------------------------
        // Assertions
        // ---------------------------------------------------------------------

        expect(
          remainingLoginButtons,
          findsNothing,
        );

        expect(
          remainingEmailFields,
          findsNothing,
        );

        expect(
          remainingPasswordFields,
          findsNothing,
        );

        debugPrint('🧪 Navigation settled');

        debugPrint(
          '🧪 Remaining Login buttons: 0',
        );

        debugPrint(
          '🧪 Remaining email fields: 0',
        );

        debugPrint(
          '🧪 Remaining password fields: 0',
        );

        debugPrint(
          '🧪 TextFields currently in tree: '
              '${remainingTextFields.evaluate().length}',
        );

        debugPrint(
          '✅ Login screen is no longer present',
        );

        // ---------------------------------------------------------------------
        // IMPORTANT:
        //
        // Remove the application from the widget tree BEFORE the test exits.
        // ---------------------------------------------------------------------

        await _cleanupTestApp(t);

        debugPrint(
          '🏁 SUCCESSFUL LOGIN TEST COMPLETE',
        );
      },
    );

    // =========================================================================
    // WRONG CREDENTIALS
    // =========================================================================

    testWidgets(
      'wrong credentials → error shown, stays on login',
          (t) async {
        await t.pumpWidget(
          _buildApp(
            loginResp: apiFail(
              'Invalid credentials',
              401,
            ),
          ),
        );

        await t.pumpAndSettle();

        // ---------------------------------------------------------------------
        // Locate fields
        // ---------------------------------------------------------------------

        final emailField = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                'e.g. name@email.com';
          },
        );

        final passwordField = find.byWidgetPredicate(
              (widget) {
            if (widget is! TextField) {
              return false;
            }

            return widget.decoration?.hintText ==
                '••••••••';
          },
        );

        expect(
          emailField,
          findsOneWidget,
        );

        expect(
          passwordField,
          findsOneWidget,
        );

        // ---------------------------------------------------------------------
        // Enter invalid credentials
        // ---------------------------------------------------------------------

        await t.enterText(
          emailField,
          'bad@email.com',
        );

        await t.enterText(
          passwordField,
          'wrongpass',
        );

        // ---------------------------------------------------------------------
        // Submit
        // ---------------------------------------------------------------------

        final loginButton = find.widgetWithText(
          ElevatedButton,
          'Login',
        );

        expect(
          loginButton,
          findsOneWidget,
        );

        await t.tap(loginButton);

        await t.pump();

        // Let the async error/snackbar operation execute.
        await t.pump(
          const Duration(milliseconds: 500),
        );

        // ---------------------------------------------------------------------
        // Error must be displayed.
        // ---------------------------------------------------------------------

        final errorFinder = find.textContaining(
          'Invalid credentials',
        );

        expect(
          errorFinder,
          findsOneWidget,
        );

        // ---------------------------------------------------------------------
        // LoginScreen must remain visible.
        // ---------------------------------------------------------------------

        expect(
          find.byType(TextField),
          findsNWidgets(2),
        );

        expect(
          find.widgetWithText(
            ElevatedButton,
            'Login',
          ),
          findsOneWidget,
        );

        // ---------------------------------------------------------------------
        // Diagnostics
        // ---------------------------------------------------------------------

        debugPrint('🧪 WRONG LOGIN');

        debugPrint(
          '🧪 Error widgets: '
              '${errorFinder.evaluate().length}',
        );

        debugPrint(
          '🧪 Login buttons: '
              '${find.widgetWithText(ElevatedButton, 'Login').evaluate().length}',
        );

        debugPrint(
          '🧪 Email fields: '
              '${emailField.evaluate().length}',
        );

        debugPrint(
          '🧪 Password fields: '
              '${passwordField.evaluate().length}',
        );

        debugPrint(
          '✅ Wrong credentials stay on LoginScreen',
        );

        // ---------------------------------------------------------------------
        // IMPORTANT:
        //
        // Close the snackbar BEFORE removing the application.
        // ---------------------------------------------------------------------

        try {
          if (Get.isSnackbarOpen) {
            Get.closeAllSnackbars();
          }
        } catch (_) {}

        // Allow snackbar animation to finish.
        await t.pump(
          const Duration(milliseconds: 200),
        );

        // ---------------------------------------------------------------------
        // Remove the complete application from the Flutter widget tree.
        // ---------------------------------------------------------------------

        await _cleanupTestApp(t);

        debugPrint(
          '🏁 WRONG CREDENTIALS TEST COMPLETE',
        );
      },
    );
  });
}