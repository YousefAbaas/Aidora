import 'platform_helper.dart';

class ApiConstants {
  ApiConstants._();

  static const String _realDeviceIp = '';

  static String get baseUrl {
    if (_realDeviceIp.isNotEmpty) return 'http://$_realDeviceIp:8000';
    return getPlatformBaseUrl();
  }

  // ── Organizations ─────────────────────────────────────────────────────────
  static const String organizationCards    = '/api/organizations/cards/';
  static String organizationFilter(String t) => '/api/organizations/filter/$t/';
  static String organizationDetail(int id)   => '/api/organizations/$id/';
  static const String organizationServices   = '/api/organizations/services/';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login           = '/api/auth/login/';
  static const String registerRefugee = '/api/auth/register/refugee/';
  static const String tokenRefresh    = '/api/auth/token/refresh/';
  static const String authMe          = '/api/auth/me/';
  static const String logout          = '/api/auth/logout/';
  static const String resendPin       = '/api/auth/resend-pin/';
  static const String verifyPin       = '/api/auth/verify-pin/';
  static const String verifyOtp       = '/api/auth/verify-otp/';
  static const String resendOtp        = '/api/auth/resend-otp/';
  static const String forgotPassword  = '/api/auth/forgot-password/';
  static const String resetPassword   = '/api/auth/reset-password/';
  static const String registerVolunteer = '/api/auth/register/volunteer/';

  /// PATCH (requires auth) — complete/update refugee profile
  static const String completeProfile = '/api/auth/refugees/complete-profile/';

  /// GET  (requires auth) — refugee profile data
  static const String refugeeProfile  = '/api/auth/profile/refugee/';

  /// POST (requires auth) — upload profile image
  static const String uploadProfileImage  = '/api/auth/profile/upload-image/';
  static const String deleteProfileImage  = '/api/auth/profile/delete-image/';

  static const String notifications = '/api/auth/notifications/';

  // ── Requests ──────────────────────────────────────────────────────────────
  /// GET /api/requests/<orgId>/services/   → [{id, name, icon}]
  static String orgServices(int orgId) => '/api/requests/$orgId/services/';

  /// POST /api/requests/<orgId>/createrequest/
  ///   body: {service, family_members, urgency_level, description, location}
  static String createRequest(int orgId) => '/api/requests/$orgId/createrequest/';
  static const String myRequests  = '/api/requests/my-requests/';
  static const String requestList = '/api/requests/list/';
  // scanQr is built dynamically: /api/requests/{pk}/scan-qr/
  /// GET — volunteer QR code: /api/auth/volunteers/{id}/qr/
  static String volunteerQr(int volunteerId) => '/api/auth/volunteers/$volunteerId/qr/';

  // ── Volunteer endpoints (from new project) ──────────────────────────────
  static const String volunteerPageOne      = '/api/auth/volunteer/profile/';
  static const String volunteerPageTwo      = '/api/auth/volunteer/profile/availability/';
  static const String volunteerPageThree    = '/api/auth/volunteer/profile/skills/';
  static const String volunteerPageFour     = '/api/organizations/';
  static const String volunteerPageFive     = '/api/auth/org/';
  static const String volunteerStateRequest = '/api/auth/me/';
  static const String volunteerProfile      = '/api/auth/volunteer/profile/view/';
  static const String volunteerHome         = '/api/requests/volunteer/home/';
  static const String volunteerTasks        = '/api/requests/volunteer/tasks/';
  // ── Organization endpoints ────────────────────────────────────────────
  static const String orgPageOne            = '/api/organizations/dashboard/';
  static const String orgReport             = '/api/organizations/tasks/';
  static const String orgPageTwo            = '/api/requests/org/requests/';
  static const String orgAssignTask         = '/api/organizations/assign-task/';
  static const String orgPageThree          = '/api/organizations/tasks/';
  static const String orgPageFore           = '/api/organizations/applications/';
  static const String orgPageTwoApproved    = '/api/requests/org/requests/';
  static const String orgPageTwoRejected    = '/api/requests/org/requests/';

  /// GET /api/requests/<pk>/details/
  static String requestDetails(int pk) => '/api/requests/$pk/details/';

  /// GET  → {service_name, service_description}
  /// POST → body:{family_members, description, location}
  ///       response:{message, request_id}
  ///       if profile incomplete: {detail:"You must complete your profile first."}
  static String orgServiceRequest(int orgId, int serviceId) =>
      '/api/requests/org/$orgId/services/$serviceId/request/';
}
// already written above - just check
