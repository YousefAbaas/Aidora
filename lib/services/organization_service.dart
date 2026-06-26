import '../models/organization_api_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// OrganizationService — All organization-related API calls
/// ─────────────────────────────────────────────────────────────────────────────
class OrganizationService {
  OrganizationService._();
  static final OrganizationService instance = OrganizationService._();
  final ApiService _api = ApiService.instance;

  // ── 1. All organizations ───────────────────────────────────────────────────
  /// GET /api/organizations/cards/
  /// Response: {count, next, previous, results: [{name, logo, id}]}
  Future<OrgListResult> fetchOrganizations() async {
    final r = await _api.get(ApiConstants.organizationCards);
    if (!r.isSuccess) return OrgListResult.error(r.errorMessage!);
    try {
      final page = OrganizationsPageModel.fromJson(r.data as Map<String, dynamic>);
      return OrgListResult.success(page.results);
    } catch (e) {
      return OrgListResult.error('Parse error: $e');
    }
  }

  // ── 2. Filter by service type ──────────────────────────────────────────────
  /// GET /api/organizations/filter/<service_type>/
  /// [serviceType] must match Django exactly, e.g. "Education", "Health"
  /// Response: [{name, logo, id}]
  Future<OrgListResult> fetchFilteredOrganizations(String serviceType) async {
    final r = await _api.get(ApiConstants.organizationFilter(serviceType));
    if (!r.isSuccess) return OrgListResult.error(r.errorMessage!);
    try {
      final list = (r.data as List)
          .map((e) => OrganizationCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return OrgListResult.success(list);
    } catch (e) {
      return OrgListResult.error('Parse error: $e');
    }
  }

  // ── 3. Organization detail ─────────────────────────────────────────────────
  /// GET /api/organizations/<pk>/
  /// Response: full organization object
  Future<OrgDetailResult> fetchOrganizationDetail(int id) async {
    final r = await _api.get(ApiConstants.organizationDetail(id));
    if (!r.isSuccess) return OrgDetailResult.error(r.errorMessage!);
    try {
      final detail = OrganizationDetailModel.fromJson(r.data as Map<String, dynamic>);
      return OrgDetailResult.success(detail);
    } catch (e) {
      return OrgDetailResult.error('Parse error: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class OrgListResult {
  final bool isSuccess;
  final List<OrganizationCardModel> organizations;
  final String? errorMessage;
  const OrgListResult._({required this.isSuccess, this.organizations = const [], this.errorMessage});
  factory OrgListResult.success(List<OrganizationCardModel> orgs) =>
      OrgListResult._(isSuccess: true, organizations: orgs);
  factory OrgListResult.error(String msg) =>
      OrgListResult._(isSuccess: false, errorMessage: msg);
}

class OrgDetailResult {
  final bool isSuccess;
  final OrganizationDetailModel? organization;
  final String? errorMessage;
  const OrgDetailResult._({required this.isSuccess, this.organization, this.errorMessage});
  factory OrgDetailResult.success(OrganizationDetailModel org) =>
      OrgDetailResult._(isSuccess: true, organization: org);
  factory OrgDetailResult.error(String msg) =>
      OrgDetailResult._(isSuccess: false, errorMessage: msg);
}
