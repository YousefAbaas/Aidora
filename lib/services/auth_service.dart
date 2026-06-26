import 'api_constants.dart';
import 'api_service.dart';
import 'auth_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  final ApiService _api = ApiService.instance;

  Future<AuthResult> login({required String email, required String password}) async {
    final r = await _api.post(ApiConstants.login,
        body: {'email': email.trim(), 'password': password});
    if (!r.isSuccess) return AuthResult.error(r.errorMessage ?? 'Login failed.');
    return _storeTokens(r.data, email);
  }

  Future<RegisterResult> registerRefugee({
    required String fullName, required String phoneNumber,
    required String email, required String password,
    required String confirmPassword, required bool acceptTerms,
  }) async {
    final r = await _api.post(ApiConstants.registerRefugee, body: {
      'full_name': fullName.trim(), 'phone_number': phoneNumber.trim(),
      'email': email.trim(), 'password': password,
      'confirm_password': confirmPassword, 'accept_terms': acceptTerms,
    });
    if (!r.isSuccess) return RegisterResult.error(r.errorMessage ?? 'Registration failed.');
    final map = r.data as Map<String, dynamic>? ?? {};
    return RegisterResult.success(email: (map['email'] as String?) ?? email.trim());
  }

  Future<RegisterResult> registerVolunteer({
    required String fullName, required String phoneNumber,
    required String email, required String password,
    required String confirmPassword, required bool acceptTerms,
  }) async {
    final r = await _api.post(ApiConstants.registerVolunteer, body: {
      'full_name': fullName.trim(), 'phone_number': phoneNumber.trim(),
      'email': email.trim(), 'password': password,
      'confirm_password': confirmPassword, 'accept_terms': acceptTerms,
    });
    if (!r.isSuccess) return RegisterResult.error(r.errorMessage ?? 'Registration failed.');
    final map = r.data as Map<String, dynamic>? ?? {};
    return RegisterResult.success(email: (map['email'] as String?) ?? email.trim());
  }

  Future<AuthResult> verifyOtp({required String email, required String otp}) async {
    final r = await _api.post(ApiConstants.verifyOtp,
        body: {'email': email.trim(), 'otp': otp.trim()});
    if (!r.isSuccess) return AuthResult.error(r.errorMessage ?? 'Verification failed.');
    return AuthResult.success(role: 'verified');
  }

  Future<AuthResult> resendOtp({required String email}) async {
    final r = await _api.post(ApiConstants.resendOtp,
        body: {'email': email.trim()});
    if (!r.isSuccess) return AuthResult.error(r.errorMessage ?? 'Resend failed.');
    return AuthResult.success(role: '');
  }

  Future<AuthResult> _storeTokens(dynamic data, String email) async {
    try {
      final map = data as Map<String, dynamic>;
      final access = map['access'] as String;
      final refresh = map['refresh'] as String;
      final role = map['role'] as String? ?? 'refugee';
      await AuthStorage.saveTokens(
        accessToken: access, refreshToken: refresh, role: role,
        email: email.trim(), displayName: email.trim().split('@').first,
      );
      return AuthResult.success(role: role);
    } catch (e) {
      return AuthResult.error('Unexpected response: $e');
    }
  }


  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<AuthResult> forgotPassword({required String email}) async {
    final r = await _api.post(ApiConstants.forgotPassword,
        body: {'email': email.trim()});
    if (!r.isSuccess) return AuthResult.error(r.errorMessage ?? 'Failed to send reset link.');
    return AuthResult.success(role: '');
  }

  // ── Reset Password ─────────────────────────────────────────────────────────
  Future<AuthResult> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final r = await _api.patch(
      ApiConstants.resetPassword,
      body: {
        'uid': uid, 'token': token,
        'new_password': newPassword, 'confirm_password': confirmPassword,
      },
    );
    if (!r.isSuccess) return AuthResult.error(r.errorMessage ?? 'Password reset failed.');
    return AuthResult.success(role: '');
  }

  Future<void> logout() async {
    try {
      final refreshToken = AuthStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _api.post(ApiConstants.logout,
            body: {'refresh': refreshToken}, requiresAuth: true);
      }
    } catch (_) {}
    await AuthStorage.clear();
  }
}

class AuthResult {
  final bool isSuccess; final String role; final String? errorMessage;
  const AuthResult._({required this.isSuccess, this.role = '', this.errorMessage});
  factory AuthResult.success({required String role}) => AuthResult._(isSuccess: true, role: role);
  factory AuthResult.error(String message) => AuthResult._(isSuccess: false, errorMessage: message);
}

class RegisterResult {
  final bool isSuccess; final String email; final String? errorMessage;
  const RegisterResult._({required this.isSuccess, this.email = '', this.errorMessage});
  factory RegisterResult.success({required String email}) => RegisterResult._(isSuccess: true, email: email);
  factory RegisterResult.error(String message) => RegisterResult._(isSuccess: false, errorMessage: message);
}
