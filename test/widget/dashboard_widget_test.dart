library;

import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/profile_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/views/my_requests_screen.dart';
import 'package:aidora/views/requests_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide fail;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_service.dart';
import '../helpers/fixtures.dart';

void _initControllers() {
  if (!Get.isRegistered<BottomNavController>()) Get.put(BottomNavController());
  if (!Get.isRegistered<SettingsController>()) Get.put(SettingsController());
  if (!Get.isRegistered<ProfileController>()) Get.put(ProfileController());
  if (!Get.isRegistered<NotificationService>()) Get.put(NotificationService());
}

void _injectSvc(Map<String, ApiResponse> gets,
    {Map<String, ApiResponse> posts = const {}}) {
  final testSvc = RequestsApiService.testInstance(
    FakeApiService(gets: gets, posts: posts),
  );
  RequestsApiService.overrideForTest(testSvc);
  Get.replace<RequestsApiService>(testSvc);
}

Widget _app(Widget child) => GetMaterialApp(home: child);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Get.deleteAll(force: true);
    _initControllers();
  });

  tearDown(() async {
    RequestsApiService.resetOverride();
    await Get.deleteAll(force: true);
  });

  // ── RequestsDashboardScreen ───────────────────────────────────────────────
  group('RequestsDashboardScreen', () {
    Future<void> pumpDash(WidgetTester t, {ApiResponse? resp}) async {
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.resetPhysicalSize);

      _injectSvc({
        ApiConstants.requestList: resp ?? ok(Map.from(requestsListJson)),
      });

      await t.pumpWidget(_app(const RequestsDashboardScreen()));

      // لمعالجة الاستجابات غير المتزامنة وفك الـ Futures المعلقة
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 1));
      if (t.hasRunningAnimations) {
        await t.pumpAndSettle();
      }
    }

    testWidgets('loading indicator shown first', (t) async {
      _injectSvc({ApiConstants.requestList: ok(Map.from(requestsListJson))});
      await t.pumpWidget(_app(const RequestsDashboardScreen()));

      // نلتقط الإطار الأول قبل معالجة الـ Future
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('stat boxes render', (t) async {
      await pumpDash(t);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('Total count 8 shown', (t) async {
      await pumpDash(t);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('Approved Requests section header', (t) async {
      await pumpDash(t);
      expect(find.text('Approved Requests'), findsOneWidget);
    });

    testWidgets('approved service name in card', (t) async {
      await pumpDash(t);
      expect(find.text('Child Protection'), findsAtLeastNWidgets(1));
    });

    testWidgets('Scan QR Code button on approved card', (t) async {
      await pumpDash(t);
      expect(find.text('Scan QR Code'), findsAtLeastNWidgets(1));
    });

    testWidgets('Rejected Requests section header', (t) async {
      await pumpDash(t);
      expect(find.text('Rejected Requests'), findsOneWidget);
    });

    testWidgets('rejection reason in rejected card', (t) async {
      await pumpDash(t);
      expect(find.textContaining('Missing documents'), findsOneWidget);
    });

    testWidgets('Review Reason link shown', (t) async {
      await pumpDash(t);
      expect(find.text('Review Reason'), findsOneWidget);
    });

    testWidgets('View All link shown', (t) async {
      await pumpDash(t);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('New Request card shown', (t) async {
      await pumpDash(t);
      expect(find.text('New Request'), findsOneWidget);
      expect(find.text('Apply for aid'), findsOneWidget);
    });

    testWidgets('network error → Retry button', (t) async {
      await pumpDash(t, resp: fail('Network error', 503));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('empty response → No requests yet', (t) async {
      await pumpDash(t,
          resp: ok({
            'counts': {'All': 0, 'Approved': 0, 'Rejected': 0},
            'data': {'Approved': [], 'Rejected': []},
          }));
      expect(find.text('No requests yet'), findsOneWidget);
    });
  });

  // ── MyRequestsScreen ──────────────────────────────────────────────────────
  group('MyRequestsScreen', () {
    Future<void> pumpMine(WidgetTester t, {ApiResponse? allResp}) async {
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.resetPhysicalSize);

      _injectSvc({
        ApiConstants.requestList: allResp ?? ok(Map.from(requestsListJson)),
      });
      await t.pumpWidget(_app(const MyRequestsScreen()));

      await t.pump();
      await t.pump(const Duration(seconds: 1));
      if (t.hasRunningAnimations) {
        await t.pumpAndSettle();
      }
    }

    testWidgets('My Requests title shown', (t) async {
      await pumpMine(t);
      expect(find.text('My Requests'), findsOneWidget);
    });

    testWidgets('tab bar has all status tabs', (t) async {
      await pumpMine(t);
      for (final tab in [
        'All',
        'Approved',
        'Pending',
        'Rejected',
        'Completed'
      ]) {
        expect(find.textContaining(tab), findsOneWidget,
            reason: '$tab tab missing');
      }
    });

    testWidgets('All tab shows request cards', (t) async {
      await pumpMine(t);
      expect(find.text('Child Protection'), findsAtLeastNWidgets(1));
    });

    testWidgets('empty all → No requests message', (t) async {
      await pumpMine(t,
          allResp: ok({
            'counts': {
              'All': 0,
              'Approved': 0,
              'Rejected': 0,
              'Pending': 0,
              'Completed': 0
            },
            'data': {
              'Approved': [],
              'Rejected': [],
              'Pending': [],
              'Completed': []
            },
          }));
      expect(find.textContaining('No requests'), findsOneWidget);
    });
  });
}
