/// requests_service_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/services/api_constants.dart';
import '../helpers/fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake ApiService for requests
// ─────────────────────────────────────────────────────────────────────────────
class _FakeApi implements ApiService {
  final Map<String, ApiResponse> _gets;
  final Map<String, ApiResponse> _posts;

  _FakeApi({
    Map<String, ApiResponse> gets  = const {},
    Map<String, ApiResponse> posts = const {},
  })  : _gets  = gets,
        _posts = posts;

  @override
  Future<ApiResponse> get(String path,
      {Map<String, String>? queryParams, bool requiresAuth = false}) async {
    // Support ?status= filtered queries
    final key = queryParams != null && queryParams.isNotEmpty
        ? '$path?status=${queryParams['status']}'
        : path;
    return _gets[key] ?? _gets[path] ?? ApiResponse.error('Unmapped GET $path', code: 404);
  }

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
       Map<String, String>? headers}) async =>
      _posts[path] ?? ApiResponse.error('Unmapped POST $path', code: 404);

  @override
  Future<ApiResponse> patch(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);

  @override
  Future<ApiResponse> delete(String path,
      {bool requiresAuth = false}) async =>
      ApiResponse.error('Not mocked', code: 500);
}

ApiResponse ok(dynamic json)            => ApiResponse.success(json, code: 200);
ApiResponse fail(String m, [int c=400]) => ApiResponse.error(m, code: c);

RequestsApiService _svc({
  ApiResponse? list,
  ApiResponse? listApproved,
  ApiResponse? details,
  ApiResponse? submit,
}) =>
    RequestsApiService.testInstance(_FakeApi(
      gets: {
        if (list != null)         ApiConstants.requestList:  list,
        if (listApproved != null) '${ApiConstants.requestList}?status=approved': listApproved,
        if (details != null)      ApiConstants.requestDetails(20): details,
      },
      posts: {
        if (submit != null) ApiConstants.createRequest(1): submit,
      },
    ));

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('RequestsApiService.fetchMyRequests()', () {
    test('success — parses all counts correctly', () async {
      final result = await _svc(
        list: ok(Map<String, dynamic>.from(requestsListJson)),
      ).fetchMyRequests();

      expect(result.isSuccess,   isTrue);
      expect(result.data!.total,    8);
      expect(result.data!.approved, 3);
      expect(result.data!.rejected, 3);
    });

    test('success — approved list parsed with correct fields', () async {
      final result = await _svc(
        list: ok(Map<String, dynamic>.from(requestsListJson)),
      ).fetchMyRequests();

      final approved = result.data!.approvedRequests;
      expect(approved, hasLength(2));
      expect(approved.first.serviceName, 'Child Protection');
      expect(approved.first.sector,      'Center A');
      expect(approved.first.id,          20);
    });

    test('success — rejected list parsed with rejection reason', () async {
      final result = await _svc(
        list: ok(Map<String, dynamic>.from(requestsListJson)),
      ).fetchMyRequests();

      final rejected = result.data!.rejectedRequests;
      expect(rejected, hasLength(1));
      expect(rejected.first.rejectionReason, 'Missing documents');
    });

    test('network failure — returns error result', () async {
      final result = await _svc(
        list: fail('Connection refused', 503),
      ).fetchMyRequests();

      expect(result.isSuccess,    isFalse);
      expect(result.errorMessage, contains('Connection refused'));
    });

    test('empty lists — handled gracefully with zero counts', () async {
      final result = await _svc(list: ok({
        'counts': {'All': 0, 'Approved': 0, 'Rejected': 0},
        'data':   {'Approved': [], 'Rejected': []},
      })).fetchMyRequests();

      expect(result.isSuccess,              isTrue);
      expect(result.data!.total,            0);
      expect(result.data!.approvedRequests, isEmpty);
      expect(result.data!.rejectedRequests, isEmpty);
    });

    test('malformed JSON — returns parse error', () async {
      final result = await _svc(
        list: ok('not a map'), // wrong type
      ).fetchMyRequests();

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Parse error'));
    });
  });

  group('RequestsApiService.fetchRequestList()', () {
    test('all requests — returns RequestListResult with counts', () async {
      final result = await _svc(
        list: ok(Map<String, dynamic>.from(requestsListJson)),
      ).fetchRequestList();

      expect(result.isSuccess, isTrue);
      expect(result.counts['All'],      8);
      expect(result.counts['Approved'], 3);
    });

    test('filtered approved — returns flat list', () async {
      final result = await _svc(
        listApproved: ok(Map<String, dynamic>.from(
          requestsListFilteredApprovedJson,
        )),
      ).fetchRequestList(status: 'approved');

      expect(result.isSuccess, isTrue);
      expect(result.items,     hasLength(1));
      expect(result.items.first.status, 'approved');
    });

    test('network error — propagated as failure', () async {
      final result = await _svc(
        list: fail('Timeout', 408),
      ).fetchRequestList();

      expect(result.isSuccess, isFalse);
    });
  });

  group('RequestsApiService.fetchRequestDetails()', () {
    test('success — all detail fields parsed', () async {
      final result = await _svc(
        details: ok(Map<String, dynamic>.from(requestDetailsJson)),
      ).fetchRequestDetails(20);

      expect(result.isSuccess,              isTrue);
      expect(result.data!.organizationName, 'UNICEF');
      expect(result.data!.serviceName,      'Education');
      expect(result.data!.status,           'completed');
      expect(result.data!.familyMembers,    3);
      expect(result.data!.sector,           'Center A');
    });

    test('not found — returns error', () async {
      final result = await _svc(
        details: fail('Not found', 404),
      ).fetchRequestDetails(20);

      expect(result.isSuccess, isFalse);
    });
  });
}
