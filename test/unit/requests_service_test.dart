/// requests_service_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aidora/services/requests_api_service.dart';
import 'package:aidora/services/api_constants.dart';
import '../helpers/fixtures.dart';
import '../helpers/fake_api_service.dart';

RequestsApiService _svc({
  ApiResponse? list,
  ApiResponse? listApproved,
  ApiResponse? details,
  ApiResponse? submit,
}) =>
    RequestsApiService.testInstance(FakeApiService(
      gets: {
        if (list != null)         ApiConstants.requestList:           list,
        if (listApproved != null) '${ApiConstants.requestList}?status=approved': listApproved,
        if (details != null)      ApiConstants.requestDetails(20):    details,
      },
      posts: {
        if (submit != null) ApiConstants.createRequest(1): submit,
      },
    ));

void main() {
  group('RequestsApiService.fetchMyRequests()', () {
    test('success — parses all counts', () async {
      final r = await _svc(list: ok(Map.from(requestsListJson))).fetchMyRequests();
      expect(r.isSuccess,      isTrue);
      expect(r.data!.total,    8);
      expect(r.data!.approved, 3);
      expect(r.data!.rejected, 3);
    });

    test('approved list has correct fields', () async {
      final r = await _svc(list: ok(Map.from(requestsListJson))).fetchMyRequests();
      final first = r.data!.approvedRequests.first;
      expect(first.serviceName, 'Child Protection');
      expect(first.sector,      'Center A');
      expect(first.id,          20);
    });

    test('rejected list has rejection reason', () async {
      final r = await _svc(list: ok(Map.from(requestsListJson))).fetchMyRequests();
      expect(r.data!.rejectedRequests.first.rejectionReason, 'Missing documents');
    });

    test('network failure returns error', () async {
      final r = await _svc(list: fail('Connection refused', 503)).fetchMyRequests();
      expect(r.isSuccess,    isFalse);
      expect(r.errorMessage, contains('Connection refused'));
    });

    test('empty lists handled gracefully', () async {
      final r = await _svc(list: ok({
        'counts': {'All': 0, 'Approved': 0, 'Rejected': 0},
        'data':   {'Approved': [], 'Rejected': []},
      })).fetchMyRequests();
      expect(r.isSuccess,              isTrue);
      expect(r.data!.total,            0);
      expect(r.data!.approvedRequests, isEmpty);
    });

    test('malformed JSON returns parse error', () async {
      final r = await _svc(list: ok('not a map')).fetchMyRequests();
      expect(r.isSuccess,    isFalse);
      expect(r.errorMessage, contains('Parse error'));
    });
  });

  group('RequestsApiService.fetchRequestList()', () {
    test('all requests — returns counts', () async {
      final r = await _svc(list: ok(Map.from(requestsListJson))).fetchRequestList();
      expect(r.isSuccess,        isTrue);
      expect(r.counts['All'],    8);
      expect(r.counts['Approved'], 3);
    });

    test('filtered approved — returns flat list', () async {
      final r = await _svc(
        listApproved: ok(Map.from(requestsListFilteredApprovedJson)),
      ).fetchRequestList(status: 'approved');
      expect(r.isSuccess,           isTrue);
      expect(r.items,               hasLength(1));
      expect(r.items.first.status,  'approved');
    });

    test('network error propagated', () async {
      final r = await _svc(list: fail('Timeout', 408)).fetchRequestList();
      expect(r.isSuccess, isFalse);
    });
  });

  group('RequestsApiService.fetchRequestDetails()', () {
    test('success — all detail fields parsed', () async {
      final r = await _svc(details: ok(Map.from(requestDetailsJson)))
          .fetchRequestDetails(20);
      expect(r.isSuccess,              isTrue);
      expect(r.data!.organizationName, 'UNICEF');
      expect(r.data!.serviceName,      'Education');
      expect(r.data!.status,           'completed');
      expect(r.data!.familyMembers,    3);
      expect(r.data!.sector,           'Center A');
    });

    test('not found returns error', () async {
      final r = await _svc(details: fail('Not found', 404))
          .fetchRequestDetails(20);
      expect(r.isSuccess, isFalse);
    });
  });
}
