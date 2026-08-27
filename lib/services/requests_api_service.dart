import '../models/my_requests_model.dart';
import '../models/request_model.dart';
import 'api_client.dart';
import 'api_constants.dart';
import 'api_service.dart';

/// API service responsible for refugee service requests.
///
/// Uses [ApiClient] so real HTTP communication and fake clients can be
/// injected independently in production and tests.
class RequestsApiService {
  RequestsApiService({ApiClient? api}) : _api = api ?? ApiService.instance;

  RequestsApiService._() : _api = ApiService.instance;

  RequestsApiService._withApi(this._api);

  static final RequestsApiService instance = RequestsApiService._();

  factory RequestsApiService.testInstance(ApiClient api) =>
      RequestsApiService._withApi(api);

// Widget-test override.
  static RequestsApiService? _override;

  static void overrideForTest(RequestsApiService svc) => _override = svc;

  static void resetOverride() => _override = null;

  /// Singleton instance, respecting any test override.
  static RequestsApiService get effective => _override ?? instance;

  final ApiClient _api;

// â”€â”€ Dashboard summary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// GET /api/requests/list/
  ///
  /// Parses the list response into [MyRequestsModel] for the dashboard.
  Future<MyRequestsResult> fetchMyRequests() async {
    final r = await _api.get(
      ApiConstants.requestList,
      requiresAuth: true,
    );

    if (!r.isSuccess) {
      return MyRequestsResult.error(
        r.errorMessage ?? 'Failed to load requests.',
      );
    }

    try {
      final raw = Map<String, dynamic>.from(r.data as Map);

      final counts = raw['counts'] as Map<String, dynamic>? ?? {};
      final data = raw['data'];

      var approved = <ApprovedRequest>[];
      var rejected = <RejectedRequest>[];

      if (data is Map) {
        final approvedList = data['Approved'] as List? ?? [];

        approved = approvedList
            .map(
              (e) => ApprovedRequest.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        final rejectedList = data['Rejected'] as List? ?? [];

        rejected = rejectedList
            .map(
              (e) => RejectedRequest.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      final model = MyRequestsModel(
        refugee: RefugeeInfo(fullName: ''),
        total: (counts['All'] as num? ?? 0).toInt(),
        approved: (counts['Approved'] as num? ?? 0).toInt(),
        rejected: (counts['Rejected'] as num? ?? 0).toInt(),
        approvedRequests: approved,
        rejectedRequests: rejected,
      );

      return MyRequestsResult.success(model);
    } catch (e) {
      return MyRequestsResult.error('Parse error: $e');
    }
  }

// â”€â”€ Full list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// GET /api/requests/list/
  ///
  /// Returns all requests when [status] is null or "all".
  ///
  /// GET /api/requests/list/?status=xxx
  ///
  /// Returns filtered requests for a specific status.
  Future<RequestListResult> fetchRequestList({
    String? status,
  }) async {
    final endpoint = status != null && status != 'all'
        ? '${ApiConstants.requestList}?status=$status'
        : ApiConstants.requestList;

    final r = await _api.get(
      endpoint,
      requiresAuth: true,
    );

    if (!r.isSuccess) {
      return RequestListResult.error(
        r.errorMessage ?? 'Failed to load request list.',
      );
    }

    try {
      final raw = Map<String, dynamic>.from(r.data as Map);

      final counts = _parseCounts(
        raw['counts'] as Map<String, dynamic>? ?? {},
      );

      final items = _parseItems(
        raw['data'],
        status,
      );

      return RequestListResult.success(
        items: items,
        counts: counts,
      );
    } catch (e) {
      return RequestListResult.error('Parse error: $e');
    }
  }

// â”€â”€ Request details â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  /// GET /api/requests/<pk>/details/
  Future<RequestDetailsResult> fetchRequestDetails(int id) async {
    final r = await _api.get(
      ApiConstants.requestDetails(id),
      requiresAuth: true,
    );

    if (!r.isSuccess) {
      return RequestDetailsResult.error(
        r.errorMessage ?? 'Failed to load request details.',
      );
    }

    try {
      final json = Map<String, dynamic>.from(r.data as Map);

      return RequestDetailsResult.success(
        RequestDetailModel.fromJson(json),
      );
    } catch (e) {
      return RequestDetailsResult.error('Parse error: $e');
    }
  }

// â”€â”€ Service request information â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// GET /api/requests/org/<orgId>/services/<serviceId>/request/
  ///
  /// Fetches service information before displaying the submit form.
  Future<ServiceRequestInfoResult> fetchServiceRequestInfo(
    int orgId,
    int serviceId,
  ) async {
    final r = await _api.get(
      ApiConstants.orgServiceRequest(
        orgId,
        serviceId,
      ),
      requiresAuth: true,
    );

    if (!r.isSuccess) {
      return ServiceRequestInfoResult.error(
        r.errorMessage ?? 'Failed to load service information.',
      );
    }

    try {
      final data = r.data as Map<String, dynamic>;

      return ServiceRequestInfoResult.success(
        serviceName: data['service_name'] as String? ?? '',
        serviceDescription: data['service_description'] as String? ?? '',
      );
    } catch (e) {
      return ServiceRequestInfoResult.error('Parse error: $e');
    }
  }

// â”€â”€ Submit service request â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// POST /api/requests/org/<orgId>/services/<serviceId>/request/
  ///
  /// Body:
  /// {
  ///   family_members,
  ///   description,
  ///   location
  /// }
  ///
  /// Success:
  /// {
  ///   message,
  ///   request_id
  /// }
  Future<SubmitRequestResult> submitServiceRequest({
    required int orgId,
    required int serviceId,
    required String familyMembers,
    required String description,
    required String location,
  }) async {
    final r = await _api.post(
      ApiConstants.orgServiceRequest(
        orgId,
        serviceId,
      ),
      requiresAuth: true,
      body: {
        'family_members': familyMembers,
        'description': description,
        'location': location,
      },
    );

    if (!r.isSuccess) {
      return SubmitRequestResult.error(
        r.errorMessage ?? 'Failed to submit request.',
      );
    }

    try {
      final data = r.data as Map<String, dynamic>;

      return SubmitRequestResult.success(
        message: data['message'] as String? ?? 'Request sent successfully',
        requestId: (data['request_id'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      return SubmitRequestResult.error('Parse error: $e');
    }
  }

// â”€â”€ Parsers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Map<String, int> _parseCounts(
    Map<String, dynamic> map,
  ) {
    return {
      'All': (map['All'] as num? ?? 0).toInt(),
      'Approved': (map['Approved'] as num? ?? 0).toInt(),
      'Rejected': (map['Rejected'] as num? ?? 0).toInt(),
      'Pending': (map['Pending'] as num? ?? 0).toInt(),
      'Completed': (map['Completed'] as num? ?? 0).toInt(),
    };
  }

  List<RequestModel> _parseItems(
    dynamic data,
    String? status,
  ) {
    if (data is List) {
// Filtered response:
// data = [...]
      return data
          .map(
            (e) => RequestModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    }

    if (data is Map) {
// Full response:
//
// data = {
//   Approved: [...],
//   Rejected: [...],
//   Pending: [...],
//   Completed: [...]
// }
      final result = <RequestModel>[];

      for (final key in data.keys) {
        final list = data[key] as List? ?? [];
        result.addAll(
          list.map(
            (e) => RequestModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
      }

      return result;
    }

    return [];
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Result classes
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class MyRequestsResult {
  final bool isSuccess;
  final MyRequestsModel? data;
  final String? errorMessage;

  const MyRequestsResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory MyRequestsResult.success(
    MyRequestsModel data,
  ) {
    return MyRequestsResult._(
      isSuccess: true,
      data: data,
    );
  }

  factory MyRequestsResult.error(
    String message,
  ) {
    return MyRequestsResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class RequestListResult {
  final bool isSuccess;
  final List<RequestModel> items;
  final Map<String, int> counts;
  final String? errorMessage;

  const RequestListResult._({
    required this.isSuccess,
    this.items = const [],
    this.counts = const {},
    this.errorMessage,
  });

  factory RequestListResult.success({
    required List<RequestModel> items,
    required Map<String, int> counts,
  }) {
    return RequestListResult._(
      isSuccess: true,
      items: items,
      counts: counts,
    );
  }

  factory RequestListResult.error(
    String message,
  ) {
    return RequestListResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class ServiceRequestInfoResult {
  final bool isSuccess;
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
  }) {
    return ServiceRequestInfoResult._(
      isSuccess: true,
      serviceName: serviceName,
      serviceDescription: serviceDescription,
    );
  }

  factory ServiceRequestInfoResult.error(
    String message,
  ) {
    return ServiceRequestInfoResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class SubmitRequestResult {
  final bool isSuccess;
  final String message;
  final int requestId;
  final String? errorMessage;

  const SubmitRequestResult._({
    required this.isSuccess,
    this.message = '',
    this.requestId = 0,
    this.errorMessage,
  });

  factory SubmitRequestResult.success({
    required String message,
    required int requestId,
  }) {
    return SubmitRequestResult._(
      isSuccess: true,
      message: message,
      requestId: requestId,
    );
  }

  factory SubmitRequestResult.error(
    String message,
  ) {
    return SubmitRequestResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Request detail model
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Model for GET /api/requests/<pk>/details/
class RequestDetailModel {
  final String ref;
  final String organizationName;
  final String? organizationLogo;
  final String serviceName;
  final String status;
  final String serviceType;
  final int? familyMembers;
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
  factory RequestDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RequestDetailModel(
      ref: json['ref']?.toString() ?? '',
      organizationName: json['organization_name']?.toString() ?? '',
      organizationLogo: json['organization_logo']?.toString(),
      serviceName: json['service_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      familyMembers: (json['family_members'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString(),
      receivedAt: json['received_at']?.toString(),
      sector: json['sector']?.toString(),
    );
  }
}

class RequestDetailsResult {
  final bool isSuccess;
  final RequestDetailModel? data;
  final String? errorMessage;

  const RequestDetailsResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory RequestDetailsResult.success(
    RequestDetailModel data,
  ) {
    return RequestDetailsResult._(
      isSuccess: true,
      data: data,
    );
  }

  factory RequestDetailsResult.error(
    String message,
  ) {
    return RequestDetailsResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
