import 'package:flutter_test/flutter_test.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/models/organization_api_model.dart';
import 'package:aidora/models/my_requests_model.dart';
import 'package:aidora/models/request_model.dart';
import 'package:aidora/services/profile_api_service.dart';

void main() {
  // ── 1. URL Construction ───────────────────────────────────────────────────
  group('ApiConstants — URL construction', () {
    test('organizationCards correct', () =>
        expect(ApiConstants.organizationCards, equals('/api/organizations/cards/')));
    test('organizationFilter encodes type', () =>
        expect(ApiConstants.organizationFilter('Education'),
            equals('/api/organizations/filter/Education/')));
    test('organizationDetail builds with id', () =>
        expect(ApiConstants.organizationDetail(1), equals('/api/organizations/1/')));
    test('orgServiceRequest builds correctly', () =>
        expect(ApiConstants.orgServiceRequest(5, 10),
            equals('/api/requests/org/5/services/10/request/')));
    test('tokenRefresh is correct', () =>
        expect(ApiConstants.tokenRefresh, equals('/api/auth/token/refresh/')));
    test('login endpoint', () =>
        expect(ApiConstants.login, equals('/api/auth/login/')));
    test('registerRefugee endpoint', () =>
        expect(ApiConstants.registerRefugee, equals('/api/auth/register/refugee/')));
    test('completeProfile is PATCH endpoint', () =>
        expect(ApiConstants.completeProfile, equals('/api/auth/refugees/complete-profile/')));
    test('refugeeProfile endpoint', () =>
        expect(ApiConstants.refugeeProfile, equals('/api/auth/profile/refugee/')));
    test('uploadProfileImage is PATCH endpoint', () =>
        expect(ApiConstants.uploadProfileImage, equals('/api/auth/profile/upload-image/')));
    test('myRequests endpoint', () =>
        expect(ApiConstants.myRequests, equals('/api/requests/my-requests/')));
    test('requestList with filter query', () =>
        expect('${ApiConstants.requestList}?status=approved',
            equals('/api/requests/list/?status=approved')));
    test('authMe endpoint', () =>
        expect(ApiConstants.authMe, equals('/api/auth/me/')));
    test('all endpoints start with /', () {
      expect(ApiConstants.organizationCards[0], equals('/'));
      expect(ApiConstants.login[0], equals('/'));
      expect(ApiConstants.myRequests[0], equals('/'));
    });
  });

  // ── 2. Model Parsing ─────────────────────────────────────────────────────
  group('OrganizationCardModel', () {
    test('parses correctly', () {
      final m = OrganizationCardModel.fromJson(
          {'name': 'UNICEF', 'logo': 'http://127.0.0.1:8000/logo.png', 'id': 1});
      expect(m.id,   equals(1));
      expect(m.name, equals('UNICEF'));
      expect(m.logo, isNotEmpty);
    });
  });

  group('OrgService with id', () {
    test('parses service id', () {
      final s = OrgService.fromJson(
          {'id': 3, 'name': 'Education', 'description': 'Desc', 'icon': 'school'});
      expect(s.id, equals(3));
      expect(s.name, equals('Education'));
    });
    test('id defaults to 0 when missing', () {
      final s = OrgService.fromJson(
          {'name': 'Education', 'description': 'Desc', 'icon': 'school'});
      expect(s.id, equals(0));
    });
  });

  group('OrganizationDetailModel', () {
    test('parses services list with ids', () {
      final m = OrganizationDetailModel.fromJson({
        'name': 'UNICEF', 'title': 'Global Aid',
        'logo': 'http://127.0.0.1:8000/logo.png', 'about': 'About',
        'services': [
          {'id': 1, 'name': 'Child Protection', 'description': 'D', 'icon': 'shield'},
          {'id': 2, 'name': 'Education', 'description': 'D', 'icon': 'school'},
        ],
        'target_groups': ['Children'],
      });
      expect(m.services.length, equals(2));
      expect(m.services[0].id, equals(1));
      expect(m.services[1].id, equals(2));
    });
    test('handles missing impact images', () {
      final m = OrganizationDetailModel.fromJson({
        'name': 'T', 'title': 'T', 'logo': 'http://127.0.0.1:8000/l.png',
        'about': 'A', 'services': [], 'target_groups': [],
      });
      expect(m.impactImage1, isNull);
      expect(m.impactImage2, isNull);
    });
  });

  group('MyRequestsModel', () {
    test('parses full dashboard response', () {
      final m = MyRequestsModel.fromJson({
        'refugee': {'full_name': 'Ahmed', 'profile_image': null},
        'Total': 5, 'Approved': 2, 'Rejected': 1,
        'Approved Requests': [
          {'id': 20, 'ref': 'REF: 6', 'service_name': 'Education',
           'status': 'approved', 'sector': 'Center A', 'approved_at': '14 days ago'},
        ],
        'Rejected Requests': [
          {'id': 22, 'ref': 'REF: 6', 'service_name': 'Water',
           'rejection_reason': 'Missing docs', 'status': 'rejected'},
        ],
      });
      expect(m.total,    equals(5));
      expect(m.approved, equals(2));
      expect(m.rejected, equals(1));
      expect(m.approvedRequests[0].serviceName, equals('Education'));
      expect(m.rejectedRequests[0].rejectionReason, equals('Missing docs'));
      expect(m.refugee?.fullName, equals('Ahmed'));
    });
  });

  group('RequestModel', () {
    test('parses approved', () {
      final m = RequestModel.fromJson({
        'status': 'approved', 'ref': 'REF: 6', 'service_name': 'Education',
        'id': 25, 'sector': 'Center A', 'approved_at': '10 days ago',
      });
      expect(m.status,      equals('approved'));
      expect(m.serviceName, equals('Education'));
      expect(m.approvedAt,  equals('10 days ago'));
    });
    test('parses rejected with reason', () {
      final m = RequestModel.fromJson({
        'id': 24, 'status': 'rejected', 'ref': 'REF: 6',
        'service_name': 'Water', 'rejection_reason': 'Missing documents',
      });
      expect(m.status,          equals('rejected'));
      expect(m.rejectionReason, equals('Missing documents'));
    });
    test('parses pending', () {
      final m = RequestModel.fromJson({
        'id': 27, 'status': 'pending', 'ref': 'REF: 6',
        'service_name': 'Child Protection', 'created_at': 'Submitted 10d ago',
      });
      expect(m.status,    equals('pending'));
      expect(m.createdAt, equals('Submitted 10d ago'));
    });
    test('parses completed', () {
      final m = RequestModel.fromJson({
        'id': 23, 'status': 'completed', 'ref': 'REF: 6',
        'service_name': 'Education', 'received_at': 'Pickup 21d ago',
      });
      expect(m.status,     equals('completed'));
      expect(m.receivedAt, equals('Pickup 21d ago'));
    });
  });

  // ── 3. Result types ───────────────────────────────────────────────────────
  group('MeResult', () {
    test('success completed', () {
      final r = MeResult.success(role: 'refugee', profileCompleted: true);
      expect(r.isSuccess, isTrue);
      expect(r.profileCompleted, isTrue);
    });
    test('success incomplete', () {
      final r = MeResult.success(role: 'refugee', profileCompleted: false);
      expect(r.profileCompleted, isFalse);
    });
    test('error', () {
      final r = MeResult.error('Session expired');
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, equals('Session expired'));
    });
  });

  // ── 4. Request body validation ────────────────────────────────────────────
  group('Request bodies', () {
    test('login body fields', () {
      final b = {'email': 'ali@gmail.com', 'password': '392100'};
      expect(b.keys, containsAll(['email', 'password']));
    });
    test('register body fields', () {
      final b = {
        'full_name': 'Ali', 'phone_number': '09330',
        'email': 'ali@gmail.com', 'password': '123',
        'confirm_password': '123', 'accept_terms': true,
      };
      expect(b.keys, containsAll(
          ['full_name','phone_number','email','password','confirm_password','accept_terms']));
    });
    test('service request body fields', () {
      final b = {'family_members': '5', 'description': 'I need help', 'location': 'Homs'};
      expect(b.keys, containsAll(['family_members','description','location']));
    });
    test('token refresh body has refresh key', () {
      final b = {'refresh': 'eyJhbGciOiJIUzI1NiJ9.xxx.yyy'};
      expect(b.containsKey('refresh'), isTrue);
    });
    test('complete profile body fields', () {
      final b = {
        'gender': 'female', 'date_of_birth': '1999-01-12',
        'location': 'Homs', 'consent_given': true,
        'family_members': [{'type': 'Children', 'count': 3}],
      };
      expect(b.keys,
          containsAll(['gender','date_of_birth','location','consent_given','family_members']));
    });
    test('date_of_birth format is YYYY-MM-DD', () {
      final dob = '1999-01-12';
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dob), isTrue);
    });
  });
}
