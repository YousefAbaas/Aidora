import '../utils/image_url_helper.dart';

/// MyRequestsModel
/// Built from GET /api/requests/list/ for the dashboard.
class MyRequestsModel {
  final RefugeeInfo? refugee;
  final int total;
  final int approved;
  final int rejected;
  final List<ApprovedRequest> approvedRequests;
  final List<RejectedRequest> rejectedRequests;

  const MyRequestsModel({
    this.refugee,
    required this.total,
    required this.approved,
    required this.rejected,
    required this.approvedRequests,
    required this.rejectedRequests,
  });

  /// Parses the dashboard/list API response.
  /// Supports both the new /api/requests/list/ shape and the legacy test shape.
  factory MyRequestsModel.fromJson(Map<String, dynamic> j) {
    // â”€â”€ counts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final countsMap = j['counts'] as Map<String, dynamic>? ?? {};

    final total = (j['Total'] ?? countsMap['All'] ?? 0 as num).toInt();
    final approved =
        (j['Approved'] ?? countsMap['Approved'] ?? 0 as num).toInt();
    final rejected =
        (j['Rejected'] ?? countsMap['Rejected'] ?? 0 as num).toInt();

    // â”€â”€ data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final data = j['data'];

    // Support "Approved Requests" key (old tests) and "Approved" (API)
    List<dynamic> approvedRaw = [];
    List<dynamic> rejectedRaw = [];

    if (data is Map) {
      approvedRaw = (data['Approved'] as List?) ?? [];
      rejectedRaw = (data['Rejected'] as List?) ?? [];
    } else {
      approvedRaw = (j['Approved Requests'] as List?) ?? [];
      rejectedRaw = (j['Rejected Requests'] as List?) ?? [];
    }

    // â”€â”€ refugee â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    RefugeeInfo? refugee;
    if (j['refugee'] is Map) {
      refugee = RefugeeInfo.fromJson(j['refugee'] as Map<String, dynamic>);
    }

    return MyRequestsModel(
      refugee: refugee,
      total: total,
      approved: approved,
      rejected: rejected,
      approvedRequests: approvedRaw
          .map((e) => ApprovedRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      rejectedRequests: rejectedRaw
          .map((e) => RejectedRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class RefugeeInfo {
  final String fullName;
  final String? profileImage;
  const RefugeeInfo({required this.fullName, this.profileImage});

  factory RefugeeInfo.fromJson(Map<String, dynamic> j) => RefugeeInfo(
        fullName: j['full_name']?.toString() ?? '',
        profileImage: ImageUrlHelper.fix(j['profile_image']?.toString()),
      );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class ApprovedRequest {
  final int id;
  final String ref;
  final String serviceName;
  final String status;
  final String sector;
  final String approvedAt;

  const ApprovedRequest({
    required this.id,
    required this.ref,
    required this.serviceName,
    required this.status,
    required this.sector,
    required this.approvedAt,
  });

  factory ApprovedRequest.fromJson(Map<String, dynamic> j) => ApprovedRequest(
        id: ((j['id'] as num?) ?? 0).toInt(),
        ref: j['ref']?.toString() ?? '',
        serviceName: j['service_name']?.toString() ?? '',
        status: j['status']?.toString() ?? 'approved',
        sector: j['sector']?.toString() ?? '',
        approvedAt: j['approved_at']?.toString() ?? '',
      );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class RejectedRequest {
  final int id;
  final String ref;
  final String serviceName;
  final String rejectionReason;
  final String status;

  const RejectedRequest({
    required this.id,
    required this.ref,
    required this.serviceName,
    required this.rejectionReason,
    required this.status,
  });

  factory RejectedRequest.fromJson(Map<String, dynamic> j) => RejectedRequest(
        id: ((j['id'] as num?) ?? 0).toInt(),
        ref: j['ref']?.toString() ?? '',
        serviceName: j['service_name']?.toString() ?? '',
        rejectionReason: j['rejection_reason']?.toString() ?? '',
        status: j['status']?.toString() ?? 'rejected',
      );
}
