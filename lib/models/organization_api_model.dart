import '../utils/image_url_helper.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// organization_api_model.dart
/// Models that match the Django API responses EXACTLY.
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class OrganizationsPageModel {
  final int count;
  final String? next;
  final String? previous;
  final List<OrganizationCardModel> results;

  const OrganizationsPageModel({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory OrganizationsPageModel.fromJson(Map<String, dynamic> j) =>
      OrganizationsPageModel(
        count: j['count'] as int,
        next: j['next'] as String?,
        previous: j['previous'] as String?,
        results: (j['results'] as List)
            .map(
              (e) => OrganizationCardModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
}

class OrganizationCardModel {
  final int id;
  final String name;
  final String logo;

  const OrganizationCardModel({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory OrganizationCardModel.fromJson(Map<String, dynamic> j) =>
      OrganizationCardModel(
        id: j['id'] as int,
        name: j['name'] as String,
        logo: (j['logo'] ?? '').toString(),
      );
}

class OrganizationDetailModel {
  final String name;
  final String title;
  final String logo;
  final String about;
  final String? officialWebsite;
  final String? contactEmail;
  final String? impactImage1;
  final String? impactImage2;
  final List<OrgService> services;
  final List<String> targetGroups;

  const OrganizationDetailModel({
    required this.name,
    required this.title,
    required this.logo,
    required this.about,
    required this.services,
    required this.targetGroups,
    this.officialWebsite,
    this.contactEmail,
    this.impactImage1,
    this.impactImage2,
  });

  factory OrganizationDetailModel.fromJson(Map<String, dynamic> j) =>
      OrganizationDetailModel(
        name: j['name'] as String,
        title: j['title'] as String? ?? '',
        logo: (j['logo'] ?? '').toString(),
        about: j['about'] as String? ?? '',
        officialWebsite: j['official_website'] as String?,
        contactEmail: j['contact_email'] as String?,
        impactImage1: j['impact_image1'] == null
            ? null
            : ImageUrlHelper.fix(j['impact_image1'] as String?),
        impactImage2: j['impact_image2'] == null
            ? null
            : ImageUrlHelper.fix(j['impact_image2'] as String?),
        services: (j['services'] as List? ?? [])
            .map(
              (e) => OrgService.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
        targetGroups: (j['target_groups'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class OrgService {
  final int id;
  final String name;
  final String description;
  final String icon;

  const OrgService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory OrgService.fromJson(Map<String, dynamic> j) => OrgService(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String,
        description: j['description'] as String,
        icon: j['icon'] as String? ?? 'help_outline',
      );
}

