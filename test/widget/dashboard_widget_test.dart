/// dashboard_widget_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/notification_service.dart';
import 'package:aidora/controllers/profile_controller.dart';
import 'package:aidora/controllers/bottom_nav_controller.dart';
import 'package:aidora/controllers/settings_controller.dart';
import 'package:aidora/views/requests_dashboard_screen.dart';
import 'package:aidora/views/my_requests_screen.dart';

import '../helpers/fixtures.dart';

// ── Fake ApiService ───────────────────────────────────────────────────────────
class _FakeApi implements ApiService {
  final Map<String, ApiResponse> _gets;
  _FakeApi(this._gets);

  @override
  Future<ApiResponse> get(String path,
      {Map<String, String>? queryParams, bool requiresAuth = false}) async {
    final key = queryParams?.isNotEmpty == true
        ? '$path?status=${queryParams!['status']}'
        : path;
    return _gets[key] ?? _gets[path] ??
        ApiResponse.error('Unmapped GET $path', code: 404);
  }

  @override Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
       Map<String, String>? headers}) async =>
      ApiResponse.error('Not mocked', code: 500);
  @override Future<ApiResponse> patch(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
  @override Future<ApiResponse> delete(String path,
      {bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
}

// ── Helpers ───────────────────────────────────────────────────────────────────
void _initControllers() {
  Get.put(BottomNavController());
  Get.put(SettingsController());
  Get.put(ProfileController());
  Get.put(NotificationService());
}

void _injectSvc(Map<String, ApiResponse> gets) {
  final svc = RequestsApiService.testInstance(_FakeApi(gets));
  RequestsApiService.overrideForTest(svc);
}

Widget _app(Widget child) => GetMaterialApp(home: child);

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUp(_initControllers);
  tearDown(() {
    RequestsApiService.resetOverride();
    Get.reset();
  });

  // ── RequestsDashboardScreen ───────────────────────────────────────────────
  group('RequestsDashboardScreen', () {
    Future<void> pumpDash(WidgetTester t, {ApiResponse? resp}) async {
      _injectSvc({
        ApiConstants.requestList: resp ??
            ApiResponse.success(Map.from(requestsListJson), code: 200),
      });
      await t.pumpWidget(_app(const RequestsDashboardScreen()));
      await t.pump();                                 // starts _load()
      await t.pumpAndSettle(const Duration(seconds: 3));
    }

    testWidgets('loading indicator shown before data arrives', (t) async {
      _injectSvc({
        ApiConstants.requestList:
            ApiResponse.success(Map.from(requestsListJson), code: 200),
      });
      await t.pumpWidget(_app(const RequestsDashboardScreen()));
      await t.pump(); // one frame — still loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('stat boxes Total / Approved / Rejected render', (t) async {
      await pumpDash(t);
      expect(find.text('Total'),    findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('count 8 shown for Total', (t) async {
      await pumpDash(t);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('Approved Requests section header shown', (t) async {
      await pumpDash(t);
      expect(find.text('Approved Requests'), findsOneWidget);
    });

    testWidgets('approved service name rendered in card', (t) async {
      await pumpDash(t);
      expect(find.text('Child Protection'), findsOneWidget);
    });

    testWidgets('Scan QR Code button present on approved card', (t) async {
      await pumpDash(t);
      expect(find.text('Scan QR Code'), findsAtLeastNWidgets(1));
    });

    testWidgets('Rejected Requests section header shown', (t) async {
      await pumpDash(t);
      expect(find.text('Rejected Requests'), findsOneWidget);
    });

    testWidgets('rejection reason rendered', (t) async {
      await pumpDash(t);
      expect(find.textContaining('Missing documents'), findsOneWidget);
    });

    testWidgets('Review Reason link shown on rejected card', (t) async {
      await pumpDash(t);
      expect(find.text('Review Reason'), findsOneWidget);
    });

    testWidgets('View All link shown', (t) async {
      await pumpDash(t);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('New Request card shown', (t) async {
      await pumpDash(t);
      expect(find.text('New Request'),  findsOneWidget);
      expect(find.text('Apply for aid'), findsOneWidget);
    });

    testWidgets('network error shows Retry button', (t) async {
      await pumpDash(t,
          resp: ApiResponse.error('Network error', code: 503));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('empty response shows No requests yet', (t) async {
      await pumpDash(t,
          resp: ApiResponse.success({
            'counts': {'All': 0, 'Approved': 0, 'Rejected': 0},
            'data':   {'Approved': [], 'Rejected': []},
          }, code: 200));
      expect(find.text('No requests yet'), findsOneWidget);
    });
  });

  // ── MyRequestsScreen ──────────────────────────────────────────────────────
  group('MyRequestsScreen', () {
    Future<void> pumpMine(WidgetTester t, {ApiResponse? allResp}) async {
      _injectSvc({
        ApiConstants.requestList: allResp ??
            ApiResponse.success(Map.from(requestsListJson), code: 200),
      });
      await t.pumpWidget(_app(const MyRequestsScreen()));
      await t.pump();
      await t.pumpAndSettle(const Duration(seconds: 3));
    }

    testWidgets('My Requests title shown', (t) async {
      await pumpMine(t);
      expect(find.text('My Requests'), findsOneWidget);
    });

    testWidgets('tab bar has All, Approved, Pending, Rejected, Completed', (t) async {
      await pumpMine(t);
      expect(find.textContaining('All'),       findsOneWidget);
      expect(find.textContaining('Approved'),  findsOneWidget);
      expect(find.textContaining('Pending'),   findsOneWidget);
      expect(find.textContaining('Rejected'),  findsOneWidget);
      expect(find.textContaining('Completed'), findsOneWidget);
    });

    testWidgets('All tab shows request cards', (t) async {
      await pumpMine(t);
      expect(find.text('Child Protection'), findsAtLeastNWidgets(1));
    });

    testWidgets('empty all — shows No requests message', (t) async {
      await pumpMine(t,
          allResp: ApiResponse.success({
            'counts': {
              'All': 0, 'Approved': 0, 'Rejected': 0,
              'Pending': 0, 'Completed': 0,
            },
            'data': {
              'Approved': [], 'Rejected': [],
              'Pending': [], 'Completed': [],
            },
          }, code: 200));
      expect(find.textContaining('No requests'), findsOneWidget);
    });
  });
}
