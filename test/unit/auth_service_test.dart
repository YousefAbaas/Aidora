
    library;

    import 'package:flutter_test/flutter_test.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:aidora/services/auth_service.dart';
    import 'package:aidora/services/api_constants.dart';
    import 'package:aidora/services/api_service.dart';

    import '../helpers/fixtures.dart';
    import '../helpers/fake_api_service.dart';

    AuthService _svc({
    ApiResponse? login,
    ApiResponse? registerRefugee,
    ApiResponse? registerVolunteer,
    ApiResponse? forgot,
    }) =>
    AuthService.testInstance(
    FakeApiService(
    posts: {
    if (login != null) ApiConstants.login: login,
    if (registerRefugee != null)
    ApiConstants.registerRefugee: registerRefugee,
    if (registerVolunteer != null)
    ApiConstants.registerVolunteer: registerVolunteer,
    if (forgot != null) ApiConstants.forgotPassword: forgot,
    },
    ),
    );

    void main() {
    TestWidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues({});

    group('AuthService.login()', () {
    test('refugee login returns role refugee', () async {
    final r = await _svc(
    login: ok(Map.from(loginSuccessJson)),
    ).login(
    email: 'ahmed@example.com',
    password: 'pass',
    );

    expect(
    r.isSuccess,
    isTrue,
    reason: 'AuthService.login failed: ${r.errorMessage}',
    );
    expect(r.role, 'refugee');
    });

    test('volunteer login returns role volunteer', () async {
    final r = await _svc(
    login: ok(Map.from(loginVolunteerJson)),
    ).login(
    email: 'v@v.com',
    password: 'pass',
    );

    expect(r.isSuccess, isTrue);
    expect(r.role, 'volunteer');
    });

    test('org login returns role organization', () async {
    final r = await _svc(
    login: ok(Map.from(loginOrgJson)),
    ).login(
    email: 'org@ngo.com',
    password: 'pass',
    );

    expect(r.isSuccess, isTrue);
    expect(r.role, 'organization');
    });

    test('wrong credentials → isSuccess false with message', () async {
    final r = await _svc(
    login: apiFail('Invalid credentials', 401),
    ).login(
    email: 'x@x.com',
    password: 'wrong',
    );

    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, contains('Invalid credentials'));
    });

    test('missing tokens in response → isSuccess false', () async {
    final r = await _svc(
    login: ok({'message': 'ok'}),
    ).login(
    email: 'a@b.com',
    password: 'pass',
    );

    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, contains('Unexpected'));
    });

    test('network error → isSuccess false', () async {
    final r = await _svc(
    login: apiFail('Connection refused', 503),
    ).login(
    email: 'a@b.com',
    password: 'pass',
    );

    expect(r.isSuccess, isFalse);
    });
    });

    group('AuthService.registerRefugee()', () {
    test('success returns email', () async {
    final r = await _svc(
    registerRefugee: ok(Map.from(registerSuccessJson)),
    ).registerRefugee(
    fullName: 'Ahmed',
    phoneNumber: '+970',
    email: 'newuser@example.com',
    password: 'P1!',
    confirmPassword: 'P1!',
    acceptTerms: true,
    );

    expect(r.isSuccess, isTrue);
    expect(r.email, 'newuser@example.com');
    });

    test('duplicate email → error propagated', () async {
    final r = await _svc(
    registerRefugee: apiFail('Email already exists.', 400),
    ).registerRefugee(
    fullName: 'X',
    phoneNumber: '0',
    email: 'taken@ex.com',
    password: 'P',
    confirmPassword: 'P',
    acceptTerms: true,
    );

    expect(r.isSuccess, isFalse);
    expect(r.errorMessage, contains('Email already exists'));
    });
    });

    group('AuthService.registerVolunteer()', () {
    test('success same contract as registerRefugee', () async {
    final r = await _svc(
    registerVolunteer: ok(Map.from(registerSuccessJson)),
    ).registerVolunteer(
    fullName: 'Alex',
    phoneNumber: '+1234',
    email: 'newuser@example.com',
    password: 'P1!',
    confirmPassword: 'P1!',
    acceptTerms: true,
    );

    expect(r.isSuccess, isTrue);
    expect(r.email, 'newuser@example.com');
    });
    });

    group('AuthService.forgotPassword()', () {
    test('known email succeeds', () async {
    final r = await _svc(
    forgot: ok({'message': 'OTP sent.'}),
    ).forgotPassword(
    email: 'ahmed@example.com',
    );

    expect(r.isSuccess, isTrue);
    });

    test('unknown email fails', () async {
    final r = await _svc(
    forgot: apiFail('User not found.', 404),
    ).forgotPassword(
    email: 'nobody@x.com',
    );

    expect(r.isSuccess, isFalse);
    });
    });
    }