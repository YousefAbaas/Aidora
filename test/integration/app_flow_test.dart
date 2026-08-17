library;

import 'dart:io';

import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/controllers/profile_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide fail;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// الرجوع للخلف للخروج من مجلد integration والتوجيه لـ helpers
import '../helpers/fake_api_service.dart';
import '../helpers/fixtures.dart';

class TestHttpOverrides extends HttpOverrides {}

Widget _buildApp({required dynamic loginResp, String? role}) {
  Get.reset();

  final fakeApi = FakeApiService(
    posts: {ApiConstants.login: loginResp},
    gets: {
      ApiConstants.refugeeProfile: ok(Map.from(refugeeProfileJson)),
      ApiConstants.requestList: ok(Map.from(requestsListJson)),
      ApiConstants.notifications: ok({'results': [], 'unread_count': 0}),
    },
  );

  AuthService.overrideForTest(fakeApi);
  RequestsApiService.overrideForTest(RequestsApiService.testInstance(fakeApi));

  return GetMaterialApp(
    home: Builder(
      builder: (context) {
        Get.put(BottomNavController());
        Get.put(SettingsController());
        Get.put(ProfileController());
        Get.put(NotificationService());
        Get.put(FormController());

        return LoginScreen(role: role);
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();

  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    await WidgetsBinding.instance.endOfFrame;

    AuthService.resetOverride();
    RequestsApiService.resetOverride();
    Get.reset();
  });

  group('Login → navigate flow', () {
    testWidgets('successful login navigates away from LoginScreen', (t) async {
      await t.pumpWidget(_buildApp(loginResp: ok(Map.from(loginSuccessJson))));
      await t.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));

      await t.enterText(find.byType(TextField).first, 'ahmed@example.com');
      await t.enterText(find.byType(TextField).last, 'pass1234');

      await t.tap(find.widgetWithText(ElevatedButton, 'Login'));

      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      await t.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('wrong credentials → error shown, stays on login', (t) async {
      await t
          .pumpWidget(_buildApp(loginResp: fail('Invalid credentials', 401)));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField).first, 'bad@email.com');
      await t.enterText(find.byType(TextField).last, 'wrongpass');

      await t.tap(find.widgetWithText(ElevatedButton, 'Login'));

      await t.pump();
      await t.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      Get.closeAllSnackbars();
      await t.pumpAndSettle();
    });
  });
}
