import 'package:get/get.dart';
import '../models/request_model.dart';
import '../services/requests_api_service.dart';

/// RequestsController â€” manages the user's request list from the real API.
/// Fetches from GET /api/requests/list/ and exposes reactive state.
class RequestsController extends GetxController {
  final RxList<RequestModel> allRequests = <RequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final _apiSvc = RequestsApiService.instance;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests({String? status}) async {
    isLoading.value = true;
    error.value = '';
    final result = await _apiSvc.fetchRequestList(status: status);
    isLoading.value = false;
    if (result.isSuccess) {
      allRequests.assignAll(result.items);
    } else {
      error.value = result.errorMessage ?? 'Failed to load requests.';
    }
  }

  void updateRequestStatus(String id, String newStatus) {
    final i = allRequests.indexWhere((r) => r.id == id);
    if (i != -1) allRequests[i] = allRequests[i].copyWith(status: newStatus);
  }

  List<RequestModel> getByStatus(String status) {
    if (status == 'all') return allRequests.toList();
    return allRequests
        .where((r) => r.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  int countByStatus(String status) {
    if (status == 'all') return allRequests.length;
    return allRequests
        .where((r) => r.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  int get totalCount => allRequests.length;
  int get approvedCount => countByStatus('approved');
  int get completeCount => countByStatus('completed');
  int get pendingCount => countByStatus('pending');
  int get rejectedCount => countByStatus('rejected');
}
