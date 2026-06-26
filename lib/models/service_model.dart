/// ─────────────────────────────────────────────────────────────────────────────
/// ServiceModel
/// Matches one item from GET /api/organizations/services/
/// JSON: {"service_type": "Education", "icon": "school"}
/// ─────────────────────────────────────────────────────────────────────────────
class ServiceModel {
  final String serviceType;
  final String icon;

  const ServiceModel({required this.serviceType, required this.icon});

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        serviceType: j['service_type'] as String,
        icon:        j['icon']         as String? ?? 'help_outline',
      );
}
