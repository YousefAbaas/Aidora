import 'dart:async';

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
  if (!Get.isRegistered<BottomNavController>()) {
    Get.put(BottomNavController());
  }

  if (!Get.isRegistered<SettingsController>()) {
    Get.put(SettingsController());
  }

  if (!Get.isRegistered<ProfileController>()) {
    Get.put(ProfileController());
  }

  if (!Get.isRegistered<NotificationService>()) {
    Get.put(NotificationService());
  }
}

// ============================================================================
// INJECT FAKE API SERVICE
// ============================================================================

void _injectSvc(
  Map<String, ApiResponse> gets, {
  Map<String, ApiResponse> posts = const {},
  Map<String, Future<ApiResponse>> getFutures = const {},
}) {
  final testSvc = RequestsApiService.testInstance(
    FakeApiService(
      gets: gets,
      posts: posts,
      getFutures: getFutures,
    ),
  );

  RequestsApiService.overrideForTest(testSvc);

  Get.replace<RequestsApiService>(testSvc);
}

// ============================================================================
// TEST APP WRAPPER
// ============================================================================

Widget _app(Widget child) {
  return GetMaterialApp(
    home: child,
  );
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------------
  // SETUP
  // --------------------------------------------------------------------------

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    await Get.deleteAll(force: true);

    _initControllers();
  });

  // --------------------------------------------------------------------------
  // TEARDOWN
  // --------------------------------------------------------------------------

  tearDown(() async {
    RequestsApiService.resetOverride();

    await Get.deleteAll(force: true);
  });

  // ==========================================================================
  // REQUESTS DASHBOARD SCREEN
  // ==========================================================================

  group('RequestsDashboardScreen', () {
    // ------------------------------------------------------------------------
    // COMMON DASHBOARD PUMP
    // ------------------------------------------------------------------------

    Future<void> pumpDash(
      WidgetTester t, {
      ApiResponse? resp,
    }) async {
      t.view.physicalSize = const Size(1080, 2400);

      t.view.devicePixelRatio = 1.0;

      addTearDown(
        t.view.resetPhysicalSize,
      );

      _injectSvc({
        ApiConstants.requestList: resp ??
            ok(
              Map<String, dynamic>.from(
                requestsListJson,
              ),
            ),
      });

      await t.pumpWidget(
        _app(
          const RequestsDashboardScreen(),
        ),
      );

      await t.pump();

      await t.pumpAndSettle();

      await t.pump();
    }
    // ------------------------------------------------------------------------
    // LOADING INDICATOR
    // ------------------------------------------------------------------------

    testWidgets(
      'loading indicator shown first',
      (t) async {
        final completer = Completer<ApiResponse>();

        _injectSvc(
          {},
          getFutures: {
            ApiConstants.requestList: completer.future,
          },
        );

        await t.pumpWidget(
          _app(
            const RequestsDashboardScreen(),
          ),
        );

// Allow initState / controller logic to start.
        await t.pump();

// The Future is still pending here, so the screen
// should still be showing its loading state.
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

// Finish the fake request.
        completer.complete(
          ok(
            Map<String, dynamic>.from(
              requestsListJson,
            ),
          ),
        );

        await t.pump();

        await t.pumpAndSettle();
      },
    );

    // ------------------------------------------------------------------------
    // STAT BOXES
    // ------------------------------------------------------------------------

    testWidgets(
      'stat boxes render',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Total'),
          findsAtLeastNWidgets(1),
        );

        expect(
          find.text('Approved'),
          findsAtLeastNWidgets(1),
        );

        expect(
          find.text('Rejected'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    // ------------------------------------------------------------------------
    // TOTAL COUNT
    // ------------------------------------------------------------------------

    testWidgets(
      'Total count 8 shown',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('8'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // APPROVED REQUESTS HEADER
    // ------------------------------------------------------------------------

    testWidgets(
      'Approved Requests section header',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Approved Requests'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // APPROVED SERVICE NAME
    // ------------------------------------------------------------------------

    testWidgets(
      'approved service name in card',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Child Protection'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    // ------------------------------------------------------------------------
    // SCAN QR CODE
    // ------------------------------------------------------------------------

    testWidgets(
      'Scan QR Code button on approved card',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Scan QR Code'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    // ------------------------------------------------------------------------
    // REJECTED REQUESTS HEADER
    // ------------------------------------------------------------------------

    testWidgets(
      'Rejected Requests section header',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Rejected Requests'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // REJECTION REASON
    // ------------------------------------------------------------------------

    testWidgets(
      'rejection reason in rejected card',
      (t) async {
        await pumpDash(t);
        expect(
          find.textContaining(
            'Missing documents',
          ),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // REVIEW REASON
    // ------------------------------------------------------------------------

    testWidgets(
      'Review Reason link shown',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('Review Reason'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // VIEW ALL
    // ------------------------------------------------------------------------

    testWidgets(
      'View All link shown',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('View All'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    // ------------------------------------------------------------------------
    // NEW REQUEST
    // ------------------------------------------------------------------------

    testWidgets(
      'New Request card shown',
      (t) async {
        await pumpDash(t);

        expect(
          find.text('New Request'),
          findsOneWidget,
        );

        expect(
          find.text('Apply for aid'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // NETWORK ERROR
    // ------------------------------------------------------------------------

    testWidgets(
      'network error -> Retry button',
      (t) async {
        await pumpDash(
          t,
          resp: apiFail(
            'Network error',
            503,
          ),
        );

        expect(
          find.text('Retry'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // EMPTY RESPONSE
    // ------------------------------------------------------------------------

    testWidgets(
      'empty response -> No requests yet',
      (t) async {
        await pumpDash(
          t,
          resp: ok({
            'counts': {
              'All': 0,
              'Approved': 0,
              'Rejected': 0,
            },
            'data': {
              'Approved': [],
              'Rejected': [],
            },
          }),
        );

        expect(
          find.text('No requests yet'),
          findsOneWidget,
        );
      },
    );
  });

  // ==========================================================================
  // MY REQUESTS SCREEN
  // ==========================================================================

  group('MyRequestsScreen', () {
    // ------------------------------------------------------------------------
    //
    Future<void> pumpMine(
      WidgetTester t, {
      ApiResponse? allResp,
    }) async {
      t.view.physicalSize = const Size(1080, 2400);

      t.view.devicePixelRatio = 1.0;

      addTearDown(
        t.view.resetPhysicalSize,
      );

      _injectSvc({
        ApiConstants.requestList: allResp ??
            ok(
              Map<String, dynamic>.from(
                requestsListJson,
              ),
            ),
      });

      await t.pumpWidget(
        _app(
          const MyRequestsScreen(),
        ),
      );

      await t.pump();

      await t.pumpAndSettle();

      await t.pump();
    }

    // ------------------------------------------------------------------------
    // TITLE
    // ------------------------------------------------------------------------

    testWidgets(
      'My Requests title shown',
      (t) async {
        await pumpMine(t);

        expect(
          find.text('My Requests'),
          findsOneWidget,
        );
      },
    );

    // ------------------------------------------------------------------------
    // STATUS TABS
    //
    // We deliberately search for the tab text itself instead of:
    //
    // Find.textContaining('Approved')
    //
    // Because the screen also contains "Approved" inside request cards.
    // ------------------------------------------------------------------------

    testWidgets(
      'tab bar has all status tabs',
      (t) async {
        await pumpMine(t);

        // ALL
        expect(
          find.byWidgetPredicate(
            (widget) {
              if (widget is! Text) {
                return false;
              }

              final text = widget.data;

              return text != null && text.startsWith('All (');
            },
          ),
          findsOneWidget,
          reason: 'All tab missing',
        );

        // APPROVED
        expect(
          find.byWidgetPredicate(
            (widget) {
              if (widget is! Text) {
                return false;
              }

              final text = widget.data;

              return text != null && text.startsWith('Approved (');
            },
          ),
          findsOneWidget,
          reason: 'Approved tab missing',
        );

        // PENDING
        expect(
          find.byWidgetPredicate(
            (widget) {
              if (widget is! Text) {
                return false;
              }

              final text = widget.data;

              return text != null && text.startsWith('Pending (');
            },
          ),
          findsOneWidget,
          reason: 'Pending tab missing',
        );

        // REJECTED
        expect(
          find.byWidgetPredicate(
            (widget) {
              if (widget is! Text) {
                return false;
              }

              final text = widget.data;

              return text != null && text.startsWith('Rejected (');
            },
          ),
          findsOneWidget,
          reason: 'Rejected tab missing',
        );

        // COMPLETED
        expect(
          find.byWidgetPredicate(
            (widget) {
              if (widget is! Text) {
                return false;
              }

              final text = widget.data;

              return text != null && text.startsWith('Completed (');
            },
          ),
          findsOneWidget,
          reason: 'Completed tab missing',
        );
      },
    );

    // ------------------------------------------------------------------------
    // ALL TAB REQUEST CARDS
    // ------------------------------------------------------------------------

    testWidgets(
      'All tab shows request cards',
      (t) async {
        await pumpMine(t);

        expect(
          find.text('Child Protection'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    // --------------------------------------
    testWidgets(
      'empty all -> No requests message',
      (t) async {
        await pumpMine(
          t,
          allResp: ok({
            'counts': {
              'All': 0,
              'Approved': 0,
              'Rejected': 0,
              'Pending': 0,
              'Completed': 0,
            },
            'data': {
              'Approved': [],
              'Rejected': [],
              'Pending': [],
              'Completed': [],
            },
          }),
        );

        expect(
          find.textContaining(
            'No requests',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
