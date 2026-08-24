import '../models/organization_api_model.dart';
import 'api_constants.dart';
import 'api_client.dart';
import 'api_service.dart';

class OrganizationService {
  OrganizationService._(this._api);

  static final OrganizationService instance =
      OrganizationService._(ApiService.instance);

  OrganizationService._withApi(ApiClient api) : _api = api;

  factory OrganizationService.testInstance(ApiClient api) =>
      OrganizationService._withApi(api);

  static OrganizationService? _override;

  static void overrideForTest(OrganizationService service) {
    _override = service;
  }

  static void resetOverride() {
    _override = null;
  }

  static OrganizationService get effective => _override ?? instance;

  final ApiClient _api;

  Future<OrgListResult> fetchOrganizations() async {
    final r = await _api.get(ApiConstants.organizationCards);

    if (!r.isSuccess) {
      return OrgListResult.error(
        r.errorMessage ?? 'Failed to load organizations.',
      );
    }

    try {
      final page = OrganizationsPageModel.fromJson(
        r.data as Map<String, dynamic>,
      );

      return OrgListResult.success(page.results);
    } catch (e) {
      return OrgListResult.error('Parse error: $e');
    }
  }

  Future<OrgListResult> fetchFilteredOrganizations(
    String serviceType,
  ) async {
    final r = await _api.get(
      ApiConstants.organizationFilter(serviceType),
    );

    if (!r.isSuccess) {
      return OrgListResult.error(
        r.errorMessage ?? 'Failed to load filtered organizations.',
      );
    }

    try {
      final list = (r.data as List)
          .map(
            (e) => OrganizationCardModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      return OrgListResult.success(list);
    } catch (e) {
      return OrgListResult.error('Parse error: $e');
    }
  }

  Future<OrgDetailResult> fetchOrganizationDetail(int id) async {
    final r = await _api.get(
      ApiConstants.organizationDetail(id),
    );

    if (!r.isSuccess) {
      return OrgDetailResult.error(
        r.errorMessage ?? 'Failed to load organization details.',
      );
    }

    try {
      final detail = OrganizationDetailModel.fromJson(
        Map<String, dynamic>.from(r.data as Map),
      );

      return OrgDetailResult.success(detail);
    } catch (e) {
      return OrgDetailResult.error('Parse error: $e');
    }
  }
}

class OrgListResult {
  final bool isSuccess;
  final List<OrganizationCardModel> organizations;
  final String? errorMessage;

  const OrgListResult._({
    required this.isSuccess,
    this.organizations = const [],
    this.errorMessage,
  });

  factory OrgListResult.success(
    List<OrganizationCardModel> organizations,
  ) {
    return OrgListResult._(
      isSuccess: true,
      organizations: organizations,
    );
  }

  factory OrgListResult.error(String message) {
    return OrgListResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class OrgDetailResult {
  final bool isSuccess;
  final OrganizationDetailModel? organization;
  final String? errorMessage;

  const OrgDetailResult._({
    required this.isSuccess,
    this.organization,
    this.errorMessage,
  });

  factory OrgDetailResult.success(
    OrganizationDetailModel organization,
  ) {
    return OrgDetailResult._(
      isSuccess: true,
      organization: organization,
    );
  }

  factory OrgDetailResult.error(String message) {
    return OrgDetailResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
