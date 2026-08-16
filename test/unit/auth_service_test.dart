/// auth_service_test.dart
library;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_service.dart';
import 'package:aidora/services/api_constants.dart';
import '../helpers/fixtures.dart';
class _FakeApi implements ApiService {
  final Map<String, ApiResponse> _posts;
  _FakeApi({required Map<String, ApiResponse> posts}) : _posts = posts;

  @override
  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
        Map<String, String>? headers, bool isRetry = false}) async =>
      _posts[path] ?? ApiResponse.error('Unmapped POST $path', code: 500);

  @override
  Future<ApiResponse> get(String path,
      {Map<String, String>? queryParams, bool requiresAuth = false,
        bool isRetry = false}) async =>
      ApiResponse.error('GET not mocked', code: 500);

  @override
  Future<ApiResponse> patch(String path,
      {Map<String, dynamic>? body, bool requiresAuth = false,
        bool isRetry = false}) async =>
      ApiResponse.error('PATCH not mocked', code: 500);

  @override
  Future<ApiResponse> delete(String path,
      {bool requiresAuth = false, bool isRetry = false}) async =>
      ApiResponse.error('DELETE not mocked', code: 500);
}
ApiResponse ok(Map<String, dynamic> json) => ApiResponse.success(json, code: 200);
ApiResponse fail(String msg, [int c = 400]) => ApiResponse.error(msg, code: c);

AuthService _svc({
  ApiResponse? login,
  ApiResponse? registerRefugee,
  ApiResponse? registerVolunteer,
  ApiResponse? forgot,
}) =>
    AuthService.testInstance(_FakeApi(posts: {
      if (login != null)             ApiConstants.login:             login,
      if (registerRefugee != null)   ApiConstants.registerRefugee:   registerRefugee,
      if (registerVolunteer != null) ApiConstants.registerVolunteer: registerVolunteer,
      if (forgot != null)            ApiConstants.forgotPassword:    forgot,
    }));
//الهدف من هذا الكود:
// عزل اختبارات AuthService عن الشبكة والـ Backend بشكل كامل، مما يجعل الاختبارات سريعة، مستقلة، وقابل للتنبؤ بنتائجها.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // Mock the platform channel response for SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });
  group('AuthService.login()', () {
    test('refugee login returns role refugee', () async {
      final r = await _svc(login: ok(Map.from(loginSuccessJson)))
          .login(email: 'ahmed@example.com', password: 'pass');
      expect(r.isSuccess, isTrue);
      expect(r.role, 'refugee');
    });
    test('refugee login returns role refugee', () async {
      final r = await _svc(login: ok(Map.from(loginSuccessJson)))
          .login(email: 'ahmed@example.com', password: 'pass');

      print('DEBUG LOGIN ERROR: ${r.errorMessage}'); // سيكشف لك سبب الـ false
      expect(r.isSuccess, isTrue);
      expect(r.role, 'refugee');
    });

    test('org login returns role organization', () async {
      final r = await _svc(login: ok(Map.from(loginOrgJson)))
          .login(email: 'org@ngo.com', password: 'pass');
      expect(r.isSuccess, isTrue);
      expect(r.role, 'organization');
    });

    test('wrong credentials → isSuccess false', () async {
      final r = await _svc(login: fail('Invalid credentials', 401))
          .login(email: 'x@x.com', password: 'wrong');
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('Invalid credentials'));
    });

    test('missing tokens in response → isSuccess false', () async {
      final r = await _svc(login: ok({'message': 'ok'}))
          .login(email: 'a@b.com', password: 'pass');
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('Unexpected'));
    });
  });

  group('AuthService.registerRefugee()', () {
    test('success returns email', () async {
      final r = await _svc(registerRefugee: ok(Map.from(registerSuccessJson)))
          .registerRefugee(
            fullName: 'Ahmed', phoneNumber: '+970',
            email: 'newuser@example.com', password: 'P1!',
            confirmPassword: 'P1!', acceptTerms: true,
          );
      expect(r.isSuccess, isTrue);
      expect(r.email, 'newuser@example.com');
    });

    test('duplicate email returns error', () async {
      final r = await _svc(registerRefugee: fail('Email already exists.', 400))
          .registerRefugee(
            fullName: 'X', phoneNumber: '0', email: 'taken@ex.com',
            password: 'P', confirmPassword: 'P', acceptTerms: true,
          );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, contains('Email already exists'));
    });
  });

  group('AuthService.registerVolunteer()', () {
    test('success same contract as registerRefugee', () async {
      final r =
          await _svc(registerVolunteer: ok(Map.from(registerSuccessJson)))
              .registerVolunteer(
                fullName: 'Alex', phoneNumber: '+1234',
                email: 'newuser@example.com', password: 'P1!',
                confirmPassword: 'P1!', acceptTerms: true,
              );
      expect(r.isSuccess, isTrue);
      expect(r.email, 'newuser@example.com');
    });
  });

  group('AuthService.forgotPassword()', () {
    test('known email succeeds', () async {
      final r = await _svc(forgot: ok({'message': 'OTP sent.'}))
          .forgotPassword(email: 'ahmed@example.com');
      expect(r.isSuccess, isTrue);
    });

    test('unknown email fails', () async {
      final r = await _svc(forgot: fail('User not found.', 404))
          .forgotPassword(email: 'nobody@x.com');
      expect(r.isSuccess, isFalse);
    });
  });
}
