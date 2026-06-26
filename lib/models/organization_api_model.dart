import '../utils/image_url_helper.dart';
/// ─────────────────────────────────────────────────────────────────────────────
/// organization_api_model.dart
/// Models that match the Django API responses EXACTLY.
/// ─────────────────────────────────────────────────────────────────────────────

// ── GET /api/organizations/cards/ ────────────────────────────────────────────
// Response: {"count":6,"next":null,"previous":null,"results":[...]}
class OrganizationsPageModel {
  final int    count;
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
        count:    j['count']    as int,
        next:     j['next']     as String?,
        previous: j['previous'] as String?,
        results: (j['results'] as List)
            .map((e) => OrganizationCardModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Single card: {"name":"UNICEF","logo":"http://...","id":1} ─────────────────
// Used by:
//   GET /api/organizations/cards/         (inside results array)
//   GET /api/organizations/filter/<type>/ (top-level array)
class OrganizationCardModel {
  final int    id;
  final String name;
  final String logo; // full URL e.g. http://127.0.0.1:8000/media/...

  const OrganizationCardModel({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory OrganizationCardModel.fromJson(Map<String, dynamic> j) =>
      OrganizationCardModel(
        id:   j['id']   as int,
        name: j['name'] as String,
        logo: ImageUrlHelper.fix(j['logo'] as String?),
      );
}

// ── GET /api/organizations/<pk>/ ─────────────────────────────────────────────
// Full detail response — all fields optional except name/logo/about
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
  final List<String>     targetGroups;

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
        name:            j['name']             as String,
        title:           j['title']            as String? ?? '',
        logo:            ImageUrlHelper.fix(j['logo'] as String?),
        about:           j['about']            as String? ?? '',
        officialWebsite: j['official_website'] as String?,
        contactEmail:    j['contact_email']    as String?,
        impactImage1:    ImageUrlHelper.fix(j['impact_image1'] as String?),
        impactImage2:    ImageUrlHelper.fix(j['impact_image2'] as String?),
        services: (j['services'] as List? ?? [])
            .map((e) => OrgService.fromJson(e as Map<String, dynamic>))
            .toList(),
        targetGroups: (j['target_groups'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

// ── Service item: {"name":"Child Protection","description":"...","icon":"shield"}
class OrgService {
  final int    id;
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
        id:          (j['id'] as num?)?.toInt() ?? 0,
        name:        j['name']        as String,
        description: j['description'] as String,
        icon:        j['icon']        as String? ?? 'help_outline',
      );
}
