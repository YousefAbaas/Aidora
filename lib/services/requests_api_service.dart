import '../models/my_requests_model.dart';
import '../models/request_model.dart';
import 'api_constants.dart';
import 'api_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// RequestsApiService
/// ─────────────────────────────────────────────────────────────────────────────
class RequestsApiService {
  RequestsApiService._();
  static final RequestsApiService instance = RequestsApiService._();
  final ApiService _api = ApiService.instance;

  // ── Dashboard summary ──────────────────────────────────────────────────────
  /// GET /api/requests/list/
  /// Parses the list response into MyRequestsModel for the dashboard.
  Future<MyRequestsResult> fetchMyRequests() async {
    final r = await _api.get(ApiConstants.requestList, requiresAuth: true);
    if (!r.isSuccess) return MyRequestsResult.error(r.errorMessage!);
    try {
      final raw    = r.data as Map<String, dynamic>;
      final counts = raw['counts'] as Map<String, dynamic>? ?? {};
      final data   = raw['data'];

      // Parse approved from data.Approved list
      List<ApprovedRequest> approved = [];
      List<RejectedRequest> rejected = [];

      if (data is Map) {
        final approvedList = data['Approved'] as List? ?? [];
        approved = approvedList
            .map((e) => ApprovedRequest.fromJson(e as Map<String, dynamic>))
            .toList();
        final rejectedList = data['Rejected'] as List? ?? [];
        rejected = rejectedList
            .map((e) => RejectedRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final model = MyRequestsModel(
        refugee:          RefugeeInfo(fullName: ''),
        total:            (counts['All']      as num? ?? 0).toInt(),
        approved:         (counts['Approved'] as num? ?? 0).toInt(),
        rejected:         (counts['Rejected'] as num? ?? 0).toInt(),
        approvedRequests: approved,
        rejectedRequests: rejected,
      );
      return MyRequestsResult.success(model);
    } catch (e) {
      return MyRequestsResult.error('Parse error: $e');
    }
  }

  // ── Full list (with optional status filter) ───────────────────────────────
  /// GET /api/requests/list/              → all requests
  /// GET /api/requests/list/?status=xxx  → filtered
  ///
  /// Response (all):      {counts:{All,Approved,Rejected,Pending,Completed},
  ///                       data:{Approved:[...], Completed:[...], ...}}
  /// Response (filtered): {counts:{...}, data:[...]}
  Future<RequestListResult> fetchRequestList({String? status}) async {
    final endpoint = status != null && status != 'all'
        ? '${ApiConstants.requestList}?status=$status'
        : ApiConstants.requestList;

    final r = await _api.get(endpoint, requiresAuth: true);
    if (!r.isSuccess) return RequestListResult.error(r.errorMessage!);

    try {
      final raw    = r.data as Map<String, dynamic>;
      final counts = _parseCounts(raw['counts'] as Map<String, dynamic>? ?? {});
      final items  = _parseItems(raw['data'], status);
      return RequestListResult.success(items: items, counts: counts);
    } catch (e) {
      return RequestListResult.error('Parse error: $e');
    }
  }

  // ── Parsers ────────────────────────────────────────────────────────────────
  Map<String, int> _parseCounts(Map<String, dynamic> m) => {
    'All':       (m['All']       as num? ?? 0).toInt(),
    'Approved':  (m['Approved']  as num? ?? 0).toInt(),
    'Rejected':  (m['Rejected']  as num? ?? 0).toInt(),
    'Pending':   (m['Pending']   as num? ?? 0).toInt(),
    'Completed': (m['Completed'] as num? ?? 0).toInt(),
  };

  List<RequestModel> _parseItems(dynamic data, String? status) {
    if (data is List) {
      // Filtered response → data is a flat list
      return data
          .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map) {
      // All response → data is {Approved:[...], Completed:[...], ...}
      final result = <RequestModel>[];
      for (final key in data.keys) {
        final list = data[key] as List? ?? [];
        result.addAll(
            list.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)));
      }
      return result;
    }
    return [];
  }
  // ── Request details ────────────────────────────────────────────────────────
  /// GET /api/requests/<pk>/details/
  Future<RequestDetailsResult> fetchRequestDetails(int id) async {
    final r = await _api.get(ApiConstants.requestDetails(id), requiresAuth: true);
    if (!r.isSuccess) return RequestDetailsResult.error(r.errorMessage!);
    try {
      final j = r.data as Map<String, dynamic>;
      return RequestDetailsResult.success(RequestDetailModel.fromJson(j));
    } catch (e) {
      return RequestDetailsResult.error('Parse error: $e');
    }
  }

  // ── Submit a service request ───────────────────────────────────────────────
  /// GET /api/requests/org/<orgId>/services/<serviceId>/request/
  /// Fetches service info before showing submit form.
  Future<ServiceRequestInfoResult> fetchServiceRequestInfo(
      int orgId, int serviceId) async {
    final r = await _api.get(
        ApiConstants.orgServiceRequest(orgId, serviceId),
        requiresAuth: true);
    if (!r.isSuccess) return ServiceRequestInfoResult.error(r.errorMessage!);
    try {
      final d = r.data as Map<String, dynamic>;
      return ServiceRequestInfoResult.success(
        serviceName:        d['service_name']        as String? ?? '',
        serviceDescription: d['service_description'] as String? ?? '',
      );
    } catch (e) {
      return ServiceRequestInfoResult.error('Parse error: $e');
    }
  }

  /// POST /api/requests/org/<orgId>/services/<serviceId>/request/
  /// Body: {family_members, description, location}
  /// Success: {message, request_id}
  Future<SubmitRequestResult> submitServiceRequest({
    required int    orgId,
    required int    serviceId,
    required String familyMembers,
    required String description,
    required String location,
  }) async {
    final r = await _api.post(
      ApiConstants.orgServiceRequest(orgId, serviceId),
      requiresAuth: true,
      body: {
        'family_members': familyMembers,
        'description':    description,
        'location':       location,
      },
    );
    if (!r.isSuccess) return SubmitRequestResult.error(r.errorMessage!);
    try {
      final d = r.data as Map<String, dynamic>;
      return SubmitRequestResult.success(
        message:   d['message']    as String? ?? 'Request sent successfully',
        requestId: (d['request_id'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      return SubmitRequestResult.error('Parse error: $e');
    }
  }

}

// ─────────────────────────────────────────────────────────────────────────────
class MyRequestsResult {
  final bool isSuccess;
  final MyRequestsModel? data;
  final String? errorMessage;
  const MyRequestsResult._({required this.isSuccess, this.data, this.errorMessage});
  factory MyRequestsResult.success(MyRequestsModel d) =>
      MyRequestsResult._(isSuccess: true, data: d);
  factory MyRequestsResult.error(String msg) =>
      MyRequestsResult._(isSuccess: false, errorMessage: msg);
}

class RequestListResult {
  final bool isSuccess;
  final List<RequestModel> items;
  final Map<String, int>   counts;
  final String? errorMessage;
  const RequestListResult._({
    required this.isSuccess,
    this.items = const [],
    this.counts = const {},
    this.errorMessage,
  });
  factory RequestListResult.success({
    required List<RequestModel> items,
    required Map<String, int>   counts,
  }) => RequestListResult._(isSuccess: true, items: items, counts: counts);
  factory RequestListResult.error(String msg) =>
      RequestListResult._(isSuccess: false, errorMessage: msg);
}

class ServiceRequestInfoResult {
  final bool   isSuccess;
  final String serviceName;
  final String serviceDescription;
  final String? errorMessage;
  const ServiceRequestInfoResult._({
    required this.isSuccess,
    this.serviceName = '',
    this.serviceDescription = '',
    this.errorMessage,
  });
  factory ServiceRequestInfoResult.success({
    required String serviceName,
    required String serviceDescription,
  }) => ServiceRequestInfoResult._(
        isSuccess: true,
        serviceName: serviceName,
        serviceDescription: serviceDescription);
  factory ServiceRequestInfoResult.error(String msg) =>
      ServiceRequestInfoResult._(isSuccess: false, errorMessage: msg);
}

class SubmitRequestResult {
  final bool   isSuccess;
  final String message;
  final int    requestId;
  final String? errorMessage;
  const SubmitRequestResult._({
    required this.isSuccess,
    this.message = '',
    this.requestId = 0,
    this.errorMessage,
  });
  factory SubmitRequestResult.success({required String message, required int requestId}) =>
      SubmitRequestResult._(isSuccess: true, message: message, requestId: requestId);
  factory SubmitRequestResult.error(String msg) =>
      SubmitRequestResult._(isSuccess: false, errorMessage: msg);
}

// ─────────────────────────────────────────────────────────────────────────────
/// Model for GET /api/requests/<pk>/details/
class RequestDetailModel {
  final String  ref;
  final String  organizationName;
  final String? organizationLogo;
  final String  serviceName;
  final String  status;
  final String  serviceType;
  final int?    familyMembers;
  final String? createdAt;
  final String? receivedAt;
  final String? sector;

  const RequestDetailModel({
    required this.ref,
    required this.organizationName,
    this.organizationLogo,
    required this.serviceName,
    required this.status,
    required this.serviceType,
    this.familyMembers,
    this.createdAt,
    this.receivedAt,
    this.sector,
  });

  factory RequestDetailModel.fromJson(Map<String, dynamic> j) =>
      RequestDetailModel(
        ref:              j['ref']?.toString()               ?? '',
        organizationName: j['organization_name']?.toString() ?? '',
        organizationLogo: j['organization_logo']?.toString(),
        serviceName:      j['service_name']?.toString()      ?? '',
        status:           j['status']?.toString()            ?? '',
        serviceType:      j['service_type']?.toString()      ?? '',
        familyMembers:    (j['family_members'] as num?)?.toInt(),
        createdAt:        j['created_at']?.toString(),
        receivedAt:       j['received_at']?.toString(),
        sector:           j['sector']?.toString(),
      );
}

class RequestDetailsResult {
  final bool isSuccess;
  final RequestDetailModel? data;
  final String? errorMessage;
  const RequestDetailsResult._({required this.isSuccess, this.data, this.errorMessage});
  factory RequestDetailsResult.success(RequestDetailModel d) =>
      RequestDetailsResult._(isSuccess: true, data: d);
  factory RequestDetailsResult.error(String msg) =>
      RequestDetailsResult._(isSuccess: false, errorMessage: msg);
}
