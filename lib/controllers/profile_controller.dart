import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/profile_api_service.dart';

/// Controller for the currently authenticated refugee profile.
///
/// The controller exposes both reactive state for GetX widgets and
/// compatibility getters used throughout the existing UI.
class ProfileController extends GetxController {
  /// Global GetX accessor used by the existing application.
  static ProfileController get to => Get.find<ProfileController>();

  /// Explicit instance accessor.
  static ProfileController get instance => Get.find<ProfileController>();

  // ---------------------------------------------------------------------------
  // Reactive state
  // ---------------------------------------------------------------------------

  final Rx<RefugeeProfileModel?> _profile =
  Rx<RefugeeProfileModel?>(null);

  final RxBool _profileLoading = false.obs;
  final RxString _profileError = ''.obs;

  final RxBool _isDeleted = false.obs;

  // Locally selected/uploaded image.
  final RxString _localImageUrl = ''.obs;

  // Prevent duplicate concurrent requests.
  bool _isLoadingProfile = false;

  // ---------------------------------------------------------------------------
  // Public reactive properties
  // ---------------------------------------------------------------------------

  /// Current refugee profile.
  Rx<RefugeeProfileModel?> get profileRx => _profile;

  /// Whether profile loading is currently in progress.
  RxBool get profileLoadingRx => _profileLoading;

  /// Profile loading error.
  RxString get profileErrorRx => _profileError;

  /// Whether the profile image was explicitly deleted.
  RxBool get isDeletedRx => _isDeleted;

  // ---------------------------------------------------------------------------
  // Public compatibility getters
  // ---------------------------------------------------------------------------

  /// Current profile model.
  RefugeeProfileModel? get profile => _profile.value;

  /// Whether profile is currently loading.
  bool get profileLoading => _profileLoading.value;

  /// Error message returned while loading the profile.
  String get profileError => _profileError.value;

  /// Whether the user explicitly deleted the profile image.
  bool get isDeleted => _isDeleted.value;

  /// Display name used by HomeScreen and RequestsDashboardScreen.
  String get displayName {
    final value = profile?.fullName.trim();

    if (value != null && value.isNotEmpty) {
      return value;
    }

    return 'User';
  }

  /// URL/path currently used for displaying the profile image.
  String get displayImageUrl {
    if (_isDeleted.value) {
      return '';
    }

    final local = _localImageUrl.value.trim();

    if (local.isNotEmpty) {
      return local;
    }

    return profile?.profileImage?.trim() ?? '';
  }

  // ---------------------------------------------------------------------------
  // Additional convenience getters
  // ---------------------------------------------------------------------------

  String get name => displayName;

  String get refugeeId => profile?.refugeeId ?? '';

  String get location => profile?.location ?? '';

  String get sectorName => profile?.sectorName ?? '';

  int get childrenCount => profile?.childrenCount ?? 0;

  int get elderlyCount => profile?.elderlyCount ?? 0;

  int get disabledCount => profile?.disabledCount ?? 0;

  int get womenCount => profile?.womenCount ?? 0;

  int get totalFamilyMembers =>
      profile?.totalFamilyMembers ?? 0;

  bool get hasProfile => profile != null;

  bool get hasImage => displayImageUrl.isNotEmpty;

  bool get hasError => profileError.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Profile loading
  // ---------------------------------------------------------------------------

  /// Loads the authenticated refugee profile.
  ///
  /// [force] allows an explicit refresh even if another request is already
  /// running.
  Future<void> loadProfile({
    bool force = false,
  }) async {
    if (_isLoadingProfile && !force) {
      debugPrint(
        '⏳ Profile already loading — skipping duplicate request',
      );
      return;
    }

    _isLoadingProfile = true;
    _profileLoading.value = true;

    if (!force) {
      _profileError.value = '';
    }

    debugPrint('👤 Loading refugee profile...');

    try {
      final result =
      await ProfileApiService.effective.fetchRefugeeProfile();

      if (result.isSuccess && result.data != null) {
        _profile.value = result.data;
        _profileError.value = '';
        _isDeleted.value = false;

        // A newly loaded server profile takes precedence over an old
        // locally selected value unless the local value was explicitly set
        // after the request.
        if (_localImageUrl.value.isEmpty) {
          final serverImage =
              result.data!.profileImage?.trim() ?? '';

          if (serverImage.isNotEmpty) {
            _localImageUrl.value = serverImage;
          }
        }

        debugPrint(
          '✅ Profile loaded: ${result.data!.fullName}',
        );
      } else {
        final message =
            result.errorMessage ?? 'Failed to load profile.';

        _profileError.value = message;

        debugPrint(
          '⚠️ Profile load failed: $message',
        );
      }
    } catch (e, stackTrace) {
      _profileError.value = 'Failed to load profile.';

      debugPrint(
        '❌ Profile controller error: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    } finally {
      _isLoadingProfile = false;
      _profileLoading.value = false;
    }
  }

  /// Clears the current profile state.
  void clearProfile() {
    _profile.value = null;
    _profileError.value = '';
    _localImageUrl.value = '';
    _isDeleted.value = false;
  }

  // ---------------------------------------------------------------------------
  // Profile image
  // ---------------------------------------------------------------------------

  /// Sets the image displayed by the UI.
  ///
  /// This method is intentionally synchronous because the image picker
  /// widget calls it immediately after selecting a local file.
  void setImage(String imageUrl) {
    final value = imageUrl.trim();

    if (value.isEmpty) {
      return;
    }

    _isDeleted.value = false;
    _localImageUrl.value = value;

    debugPrint(
      '🖼️ Profile image updated locally: $value',
    );
  }

  /// Uploads a selected XFile and updates the displayed image.
  Future<bool> uploadImage(dynamic xfile) async {
    try {
      final result = await ProfileApiService.effective
          .uploadProfileImageXFile(xfile);

      if (!result.isSuccess) {
        _profileError.value =
            result.errorMessage ?? 'Failed to upload image.';

        debugPrint(
          '❌ Profile image upload failed: ${_profileError.value}',
        );

        return false;
      }

      setImage(result.imageUrl);

      _isDeleted.value = false;
      _profileError.value = '';

      debugPrint(
        '✅ Profile image uploaded successfully',
      );

      return true;
    } catch (e) {
      _profileError.value = 'Upload error: $e';

      debugPrint(
        '❌ Profile image upload error: $e',
      );

      return false;
    }
  }

  /// Deletes the profile image from the backend.
  Future<bool> deleteImage() async {
    try {
      final result =
      await ProfileApiService.effective.deleteProfileImage();

      if (!result.isSuccess) {
        _profileError.value =
            result.errorMessage ?? 'Failed to delete image.';

        debugPrint(
          '❌ Profile image deletion failed: ${_profileError.value}',
        );

        return false;
      }

      _localImageUrl.value = '';
      _isDeleted.value = true;
      _profileError.value = '';

      // Keep the profile model synchronized with the UI.
      final current = _profile.value;

      if (current != null) {
        _profile.value = RefugeeProfileModel(
          refugeeId: current.refugeeId,
          profileImage: null,
          fullName: current.fullName,
          location: current.location,
          sectorName: current.sectorName,
          childrenCount: current.childrenCount,
          elderlyCount: current.elderlyCount,
          disabledCount: current.disabledCount,
          womenCount: current.womenCount,
          totalFamilyMembers: current.totalFamilyMembers,
        );
      }

      debugPrint(
        '✅ Profile image deleted successfully',
      );

      return true;
    } catch (e) {
      _profileError.value = 'Delete error: $e';

      debugPrint(
        '❌ Profile image deletion error: $e',
      );

      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Profile update helpers
  // ---------------------------------------------------------------------------

  /// Updates the cached profile after another part of the application changes
  /// the user's profile.
  void setProfile(RefugeeProfileModel value) {
    _profile.value = value;

    _isDeleted.value = false;

    final image = value.profileImage?.trim() ?? '';

    if (image.isNotEmpty) {
      _localImageUrl.value = image;
    } else {
      _localImageUrl.value = '';
    }

    _profileError.value = '';
  }

  /// Clears only the current error.
  void clearError() {
    _profileError.value = '';
  }

  /// Forces a fresh profile request.
  Future<void> refreshProfile() async {
    await loadProfile(force: true);
  }
}