import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../services/api_constants.dart';
import '../services/api_service.dart';
import '../utils/image_url_helper.dart';

/// VolController — single reactive source of truth for volunteer profile.
/// Pattern mirrors ProfileController used by refugees.
class VolController extends GetxController {
  static VolController get to => Get.find();

  final RxString volName      = ''.obs;
  final RxString volImageUrl  = ''.obs;
  final RxBool   isLoading    = false.obs;

  @override
  void onInit() {
    super.onInit();
    // NOTE: loadProfile() is intentionally NOT called here.
    // It is called explicitly by Navigationbarr.initState() once the
    // volunteer has logged in and a valid auth token exists.
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(
        ApiConstants.volunteerProfile,
        requiresAuth: true,
      );
      if (res.isSuccess) {
        final d = res.data as Map<String, dynamic>? ?? {};
        final name = d['full_name']?.toString() ?? '';
        final raw  = d['profile_image']?.toString() ?? '';
        volName.value     = name;
        volImageUrl.value = raw.isNotEmpty ? ImageUrlHelper.fix(raw) : '';
        debugPrint('🙋 VolController loaded: name=$name img=$raw');
      } else {
        debugPrint('❌ VolController API error: ${res.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ VolController exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update image reactively (after upload)
  void setImage(String url) {
    volImageUrl.value = url.isNotEmpty ? ImageUrlHelper.fix(url) : '';
  }
}
