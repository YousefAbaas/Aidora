import '../models/service_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

/// Fetches the list of service types from the backend.
/// Used in FilterScreen so filters are always in sync with Django.
class ServicesApiService {
  ServicesApiService._();
  static final ServicesApiService instance = ServicesApiService._();
  final ApiService _api = ApiService.instance;

  /// GET /api/organizations/services/
  /// Response: {count, results:[{service_type, icon}]}
  Future<ServicesResult> fetchServices() async {
    final r = await _api.get(ApiConstants.organizationServices);
    if (!r.isSuccess) return ServicesResult.error(r.errorMessage!);
    try {
      final data = r.data as Map<String, dynamic>;
      final list = (data['results'] as List)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ServicesResult.success(list);
    } catch (e) {
      return ServicesResult.error('Parse error: $e');
    }
  }
}

class ServicesResult {
  final bool isSuccess;
  final List<ServiceModel> services;
  final String? errorMessage;
  const ServicesResult._({required this.isSuccess, this.services = const [], this.errorMessage});
  factory ServicesResult.success(List<ServiceModel> s) =>
      ServicesResult._(isSuccess: true, services: s);
  factory ServicesResult.error(String msg) =>
      ServicesResult._(isSuccess: false, errorMessage: msg);
}
