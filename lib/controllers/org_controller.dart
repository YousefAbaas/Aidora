import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../services/api_constants.dart';
import '../services/api_service.dart';
import '../utils/image_url_helper.dart';

/// OrgController â€” single reactive source of truth for organization profile.
/// Pattern mirrors ProfileController used by refugees.
class OrgController extends GetxController {
  static OrgController get to => Get.find();

  final RxString orgName = 'Organization'.obs;
  final RxString orgLogoUrl = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // NOTE: loadProfile() is intentionally NOT called here.
    // It is called explicitly by Orgnavigationbar.initState() once the
    // organization has logged in and a valid auth token exists.
    // Calling it here would fire an authenticated API request at app
    // startup (before login), which always fails with 401 and produces
    // noisy errors during mobile debugging.
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(
        ApiConstants.orgPageOne,
        requiresAuth: true,
      );
      if (res.isSuccess) {
        final d = res.data as Map<String, dynamic>? ?? {};
        final name = d['organization_name']?.toString() ??
            d['name']?.toString() ??
            'Organization';
        final raw =
            d['organization_logo']?.toString() ?? d['logo']?.toString() ?? '';
        orgName.value = name;
        orgLogoUrl.value = raw.isNotEmpty ? ImageUrlHelper.fix(raw) : '';
        debugPrint('ðŸ¢ OrgController loaded: name=$name logo=$raw');
      } else {
        debugPrint('âŒ OrgController API error: ${res.errorMessage}');
      }
    } catch (e) {
      debugPrint('âŒ OrgController exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set logo reactively (after upload if needed in future)
  void setLogo(String url) {
    orgLogoUrl.value = url.isNotEmpty ? ImageUrlHelper.fix(url) : '';
  }
}
