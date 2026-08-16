/// models_test.dart
///
/// Pure-Dart unit tests — no Flutter widgets, no network.
/// Tests every model's fromJson / toJson / edge-cases.
///
/// Run: flutter test test/unit/models_test.dart
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:aidora/models/request_model.dart';
import 'package:aidora/models/my_requests_model.dart';
import 'package:aidora/models/organization_api_model.dart';
import 'package:aidora/utils/image_url_helper.dart';

import '../helpers/fixtures.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // RequestModel
  // ───────────────────────────────────────────────────────────────────────────
  group('RequestModel', () {
    test('fromJson — approved request parses all fields', () {
      final model = RequestModel.fromJson(
        Map<String, dynamic>.from(singleApprovedRequestJson),
      );
      expect(model.id,          '20');
      expect(model.status,      'approved');
      expect(model.ref,         'REF: 6');
      expect(model.serviceName, 'Child Protection');
      expect(model.sector,      'Center A');
      expect(model.approvedAt,  '14 days ago');
    });

    test('fromJson — rejected request includes rejectionReason', () {
      final model = RequestModel.fromJson(
        Map<String, dynamic>.from(singleRejectedRequestJson),
      );
      expect(model.status,          'rejected');
      expect(model.rejectionReason, 'Missing documents');
    });

    test('fromJson — pending request includes createdAt', () {
      final model = RequestModel.fromJson(
        Map<String, dynamic>.from(singlePendingRequestJson),
      );
      expect(model.status,    'pending');
      expect(model.createdAt, 'Submitted 10d ago');
    });

    test('fromJson — status "completed" normalises to "complete"', () {
      final model = RequestModel.fromJson({
        'id': '1', 'ref': 'R-1', 'status': 'completed', 'service_name': 'Food',
      });
      expect(model.status, 'complete');
    });

    test('fromJson — null optional fields stay null', () {
      final model = RequestModel.fromJson({
        'id': '99', 'ref': 'R-99', 'status': 'pending', 'service_name': 'Shelter',
      });
      expect(model.sector,          isNull);
      expect(model.rejectionReason, isNull);
      expect(model.orgName,         isNull);
      expect(model.familyMembers,   isNull);
    });

    test('toJson roundtrip — produces parseable JSON', () {
      final original = RequestModel.fromJson(
        Map<String, dynamic>.from(singleApprovedRequestJson),
      );
      final json  = original.toJson();
      final clone = RequestModel.fromJson(json);
      expect(clone.id,          original.id);
      expect(clone.status,      original.status);
      expect(clone.serviceName, original.serviceName);
    });

    test('copyWith — only changes the specified field', () {
      final original = RequestModel.fromJson(
        Map<String, dynamic>.from(singleApprovedRequestJson),
      );
      final copy = original.copyWith(status: 'rejected');
      expect(copy.status,      'rejected');
      expect(copy.serviceName, original.serviceName); // unchanged
      expect(copy.ref,         original.ref);         // unchanged
    });

    test('equality — two models with same id are equal', () {
      final a = RequestModel.fromJson(
          Map<String, dynamic>.from(singleApprovedRequestJson));
      final b = RequestModel.fromJson(
          Map<String, dynamic>.from(singleApprovedRequestJson));
      expect(a, equals(b));
    });

    test('legacy getters — return correct derived values', () {
      final m = RequestModel.fromJson(
        Map<String, dynamic>.from(singleApprovedRequestJson),
      );
      expect(m.title,     'Child Protection');
      expect(m.aidType,   'Child Protection');
      expect(m.refNumber, 'REF-6');
    });

    test('familyMembers — parsed from int in JSON', () {
      final m = RequestModel.fromJson({
        'id':             '5',
        'ref':            'R-5',
        'status':         'approved',
        'service_name':   'Food',
        'family_members': 6,
      });
      expect(m.familyMembers, 6);
      expect(m.sufficesFor,   6);
    });

    test('familyMembers — parsed from string in JSON', () {
      final m = RequestModel.fromJson({
        'id':             '5',
        'ref':            'R-5',
        'status':         'approved',
        'service_name':   'Food',
        'family_members': '4',
      });
      expect(m.familyMembers, 4);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // MyRequestsModel
  // ───────────────────────────────────────────────────────────────────────────
  group('MyRequestsModel', () {
    test('fromJson — new API shape (counts + data map)', () {
      final model = MyRequestsModel.fromJson(
        Map<String, dynamic>.from(requestsListJson),
      );
      expect(model.total,                 8);
      expect(model.approved,              3);
      expect(model.rejected,              3);
      expect(model.approvedRequests,      hasLength(2));
      expect(model.rejectedRequests,      hasLength(1));
    });

    test('fromJson — approved items parsed correctly', () {
      final model = MyRequestsModel.fromJson(
        Map<String, dynamic>.from(requestsListJson),
      );
      final first = model.approvedRequests.first;
      expect(first.id,          20);
      expect(first.serviceName, 'Child Protection');
      expect(first.sector,      'Center A');
      expect(first.approvedAt,  '14 days ago');
    });

    test('fromJson — rejected reason included', () {
      final model = MyRequestsModel.fromJson(
        Map<String, dynamic>.from(requestsListJson),
      );
      expect(
        model.rejectedRequests.first.rejectionReason,
        'Missing documents',
      );
    });

    test('fromJson — legacy shape (direct keys without counts)', () {
      final model = MyRequestsModel.fromJson({
        'refugee':            {'full_name': 'Ahmed', 'profile_image': null},
        'Total':              5,
        'Approved':           2,
        'Rejected':           1,
        'Approved Requests':  [
          {
            'id': 20, 'ref': 'REF: 6', 'service_name': 'Education',
            'status': 'approved', 'sector': 'Center A', 'approved_at': '14 days ago',
          },
        ],
        'Rejected Requests':  [],
      });
      expect(model.total,    5);
      expect(model.approved, 2);
      expect(model.rejected, 1);
      expect(model.approvedRequests, hasLength(1));
      expect(model.refugee?.fullName, 'Ahmed');
    });

    test('fromJson — empty lists handled gracefully', () {
      final model = MyRequestsModel.fromJson({
        'counts': {'All': 0, 'Approved': 0, 'Rejected': 0},
        'data':   {'Approved': [], 'Rejected': []},
      });
      expect(model.total,            0);
      expect(model.approvedRequests, isEmpty);
      expect(model.rejectedRequests, isEmpty);
    });

    test('RefugeeInfo.fromJson — null image stays empty string', () {
      final info = RefugeeInfo.fromJson({
        'full_name':     'Test User',
        'profile_image': null,
      });
      expect(info.fullName,     'Test User');
      expect(info.profileImage, '');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // OrganizationCardModel
  // ───────────────────────────────────────────────────────────────────────────
  group('OrganizationCardModel', () {
    test('fromJson — parses id, name, logo correctly', () {
      final card = OrganizationCardModel.fromJson({
        'id':   1,
        'name': 'UNICEF',
        'logo': 'http://127.0.0.1:8000/media/orgs/unicef.png',
      });
      expect(card.id,   1);
      expect(card.name, 'UNICEF');
      expect(card.logo, contains('media/orgs/unicef.png'));
    });

    test('fromJson — logo URL goes through ImageUrlHelper.fix()', () {
      final card = OrganizationCardModel.fromJson({
        'id':   2,
        'name': 'WFP',
        'logo': 'http://127.0.0.1:8000/media/orgs/wfp.png',
      });
      // ImageUrlHelper rewrites localhost for the current platform
      expect(ImageUrlHelper.isValid(card.logo), isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // OrganizationsPageModel
  // ───────────────────────────────────────────────────────────────────────────
  group('OrganizationsPageModel', () {
    test('fromJson — count and results parsed', () {
      final page = OrganizationsPageModel.fromJson(
        Map<String, dynamic>.from(orgCardsJson),
      );
      expect(page.count,   2);
      expect(page.results, hasLength(2));
      expect(page.next,     isNull);
      expect(page.previous, isNull);
    });

    test('fromJson — nested OrganizationCardModel items correct', () {
      final page = OrganizationsPageModel.fromJson(
        Map<String, dynamic>.from(orgCardsJson),
      );
      expect(page.results.first.name, 'UNICEF');
      expect(page.results.last.name,  'World Food Programme');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ImageUrlHelper
  // ───────────────────────────────────────────────────────────────────────────
  group('ImageUrlHelper', () {
    test('fix — null input returns empty string', () {
      expect(ImageUrlHelper.fix(null), '');
    });

    test('fix — empty string returns empty string', () {
      expect(ImageUrlHelper.fix(''),  '');
      expect(ImageUrlHelper.fix(' '), '');
    });

    test('fix — https URL is returned unchanged', () {
      const url = 'https://cdn.example.com/media/img.png';
      expect(ImageUrlHelper.fix(url), url);
    });

    test('fix — relative path is prepended with baseUrl', () {
      const path = '/media/profiles/photo.jpg';
      final result = ImageUrlHelper.fix(path);
      expect(result, endsWith('/media/profiles/photo.jpg'));
      expect(result, startsWith('http'));
    });

    test('fix — http://127.0.0.1:8000 host is replaced with platform baseUrl', () {
      const url = 'http://127.0.0.1:8000/media/orgs/logo.png';
      final result = ImageUrlHelper.fix(url);
      expect(result, contains('/media/orgs/logo.png'));
      expect(result, startsWith('http'));
    });

    test('isValid — returns true for valid fixed URL', () {
      expect(
        ImageUrlHelper.isValid('http://127.0.0.1:8000/media/img.png'),
        isTrue,
      );
    });

    test('isValid — returns false for null/empty', () {
      expect(ImageUrlHelper.isValid(null), isFalse);
      expect(ImageUrlHelper.isValid(''),   isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ApprovedRequest / RejectedRequest edge cases
  // ───────────────────────────────────────────────────────────────────────────
  group('ApprovedRequest', () {
    test('fromJson — id parsed from num', () {
      final r = ApprovedRequest.fromJson({
        'id': 42, 'ref': 'R', 'service_name': 'Food',
        'status': 'approved', 'sector': 'A', 'approved_at': 'Today',
      });
      expect(r.id, 42);
    });

    test('fromJson — missing optional fields default to empty string', () {
      final r = ApprovedRequest.fromJson({
        'id': 1, 'ref': null, 'service_name': null,
        'status': null, 'sector': null, 'approved_at': null,
      });
      expect(r.ref,         '');
      expect(r.serviceName, '');
      expect(r.status,      'approved'); // fallback
    });
  });

  group('RejectedRequest', () {
    test('fromJson — rejectionReason empty string when missing', () {
      final r = RejectedRequest.fromJson({
        'id': 1, 'ref': 'R', 'service_name': 'Food', 'status': 'rejected',
      });
      expect(r.rejectionReason, '');
    });
  });
}
