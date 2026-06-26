import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../services/auth_storage.dart';
import '../services/profile_api_service.dart';

/// ProfileController — single reactive source of truth for all profile data.
///
/// Image update flow:
///   uploadProfileImage → setImage(serverUrl) → all Obx() widgets rebuild
///
/// Login flow:
///   loadProfile() → _profile.value = data → displayName + apiImageUrl update
class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Show stored name immediately (set during login — no network wait)
    final n = AuthStorage.getName();
    if (n != null && n.isNotEmpty) _displayName.value = n;
  }

  // ── Reactive image path ────────────────────────────────────────────────────
  // null  = use API image from profile
  // ''    = deleted / use default avatar
  // url   = server URL after upload OR local path (native preview)
  final Rx<String?> imagePath = Rx<String?>(null);

  void setImage(String? url) {
    debugPrint('🖼 setImage: $url');
    imagePath.value = url;
    // Always cache server URLs so they survive local preview → server upload cycle
    if (url != null && url.startsWith('http')) {
      _serverImageUrl.value = url;
    }
  }

  Future<void> deleteImage() async {
    // Optimistically update UI
    imagePath.value = '';
    _serverImageUrl.value = null;
    // Call API to delete on server
    try {
      await ProfileApiService.instance.deleteProfileImage();
    } catch (e) {
      debugPrint('❌ deleteImage API error: $e');
    }
  }

  bool get isDeleted => imagePath.value == '';
  bool get hasLocalOverride =>
      imagePath.value != null &&
      imagePath.value!.isNotEmpty &&
      !imagePath.value!.startsWith('http');

  /// Alias for [hasLocalOverride] — used across screens for convenience.
  bool get hasCustom => hasLocalOverride;

  // Separate reactive for server image (set after upload or profile load)
  final Rx<String?> _serverImageUrl = Rx<String?>(null);

  /// The URL to display — priority:
  ///   1. '' (deleted) → null → show default avatar
  ///   2. Local path   → local file preview (native only, before upload)
  ///   3. imagePath set to http URL (after upload or login)
  ///   4. _serverImageUrl (from profile load)
  ///   5. null → show default avatar
  String? get displayImageUrl {
    if (isDeleted) return null;
    if (imagePath.value != null && imagePath.value!.isNotEmpty) {
      return imagePath.value;
    }
    return _serverImageUrl.value;
  }

  // ── API profile data ───────────────────────────────────────────────────────
  final Rxn<RefugeeProfileModel> _profile = Rxn<RefugeeProfileModel>();
  final RxBool   _loading = false.obs;
  final RxString _error   = ''.obs;
  final RxString _displayName = 'User'.obs;

  RefugeeProfileModel? get profile       => _profile.value;
  bool                 get profileLoading => _loading.value;
  String               get profileError   => _error.value;

  String get displayName =>
      _profile.value?.fullName.isNotEmpty == true
          ? _profile.value!.fullName
          : _displayName.value;

  String? get apiImageUrl => displayImageUrl;

  String get refugeeId  => _profile.value?.refugeeId  ?? '';
  String get location   => _profile.value?.location   ?? '';
  String get sectorName => _profile.value?.sectorName ?? '';

  // ── Load from API ─────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    _loading.value = true;
    _error.value   = '';
    final r = await ProfileApiService.instance.fetchRefugeeProfile();
    _loading.value = false;
    if (r.isSuccess && r.data != null) {
      _profile.value = r.data;
      final name = r.data!.fullName;
      if (name.isNotEmpty) {
        _displayName.value = name;
        AuthStorage.saveName(name);
      }
      // Always update server image from API — unless user has a local override in progress
      final apiImg = r.data!.profileImage;
      debugPrint('👤 Profile loaded: name=$name  image=$apiImg');
      if (apiImg != null && apiImg.isNotEmpty) {
        _serverImageUrl.value = apiImg;
        // Only update imagePath if we don't have a local preview in progress
        if (!hasLocalOverride) {
          imagePath.value = apiImg; // triggers Obx rebuild in all screens
          debugPrint('🖼 Profile image set: $apiImg');
        }
      }
    } else {
      _error.value = r.errorMessage ?? 'Failed to load profile.';
    }
  }
}
