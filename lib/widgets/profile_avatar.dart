import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_img_stub.dart'
    if (dart.library.html) 'web_img.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';
import '../services/profile_api_service.dart';
import '../utils/image_url_helper.dart';

/// Reactive profile avatar that auto-updates across all screens.
/// Tap to show bottom sheet for photo upload/delete.
class ProfileAvatar extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color  borderColor;
  final bool   tappable;
  final bool   showEditBadge;

  const ProfileAvatar({
    super.key,
    this.size          = 46,
    this.borderWidth   = 2,
    this.borderColor   = const Color(0xFF2C5F4F),
    this.tappable      = true,
    this.showEditBadge = false,
  });

  static const Color _green = Color(0xFF2C5F4F);

  static Future<void> showPhotoOptions(BuildContext context) async {
    await Get.bottomSheet(
      _PhotoOptionsSheet(pc: ProfileController.to),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pc = ProfileController.to;
      final avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: ClipOval(child: _imageWidget(pc)),
          ),
          if (showEditBadge)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width:  size * 0.30,
                height: size * 0.30,
                decoration: BoxDecoration(
                  color: _green, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: size * 0.16),
              ),
            ),
        ],
      );

      if (!tappable) return avatar;
      return InkWell(
        onTap: () => showPhotoOptions(context),
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    });
  }

  Widget _imageWidget(ProfileController pc) {
    if (pc.isDeleted) return _defaultAvatar();

    final url = pc.displayImageUrl;
    if (url == null || url.isEmpty) return _defaultAvatar();

    // Local file (native — just picked, before upload finishes)
    if (!kIsWeb && !url.startsWith('http')) {
      try {
        return Image.file(File(url),
            key: ValueKey(url),
            fit: BoxFit.cover, width: size, height: size);
      } catch (_) { return _defaultAvatar(); }
    }

    // Network image — fix URL for current platform
    final fixed = ImageUrlHelper.fix(url);
    if (fixed.isEmpty) return _defaultAvatar();

    if (kIsWeb) {
      // Flutter Web: Image.network ignores headers — browser handles HTTP.
      // Use cache-buster query param to force fresh load after upload.
      final webUrl =
          '$fixed${fixed.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch ~/ 60000}';
      return Image.network(
        webUrl, key: ValueKey(webUrl),
        fit: BoxFit.cover, width: size, height: size,
        errorBuilder:   (_, __, ___) => _defaultAvatar(),
        loadingBuilder: (_, child, p) => p == null ? child : _loader(),
      );
    }

    // Native: headers are supported
    return Image.network(
      fixed, key: ValueKey(fixed),
      fit: BoxFit.cover, width: size, height: size,
      headers: const {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache', 'Expires': '0',
      },
      errorBuilder:   (_, __, ___) => _defaultAvatar(),
      loadingBuilder: (_, child, p) => p == null ? child : _loader(),
    );
  }

  Widget _loader() => Container(
    color: Colors.grey[200],
    child: Center(child: SizedBox(
      width: size * 0.35, height: size * 0.35,
      child: const CircularProgressIndicator(
          strokeWidth: 2, color: Color(0xFF2C5F4F)),
    )),
  );

  Widget _defaultAvatar() => Image.asset(
    'img/profile_avatar.jpg',
    key: const ValueKey('default_avatar'),
    fit: BoxFit.cover, width: size, height: size,
    errorBuilder: (_, __, ___) => Container(
      color: Colors.grey[200],
      child: Icon(Icons.person_rounded,
          size: size * 0.55, color: Colors.grey[400]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Options Bottom Sheet — NO setState, no _uploading flag
// Upload runs in background via ProfileController (reactive)
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoOptionsSheet extends StatelessWidget {
  final ProfileController pc;
  const _PhotoOptionsSheet({required this.pc});

  static const Color _green = Color(0xFF2C5F4F);
  static final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    Get.back(); // close sheet immediately — no setState needed
    final f = await _picker.pickImage(source: source, imageQuality: 85);
    if (f == null) return;

    // Immediate local preview (reactive — updates all screens via Obx)
    pc.setImage(f.path);

    // Upload in background
    final result = await ProfileApiService.instance.uploadProfileImageXFile(f);

    if (result.isSuccess) {
      pc.setImage(result.imageUrl); // updates all Obx widgets
      _snack('Photo Updated', '✓ Profile photo uploaded.', _green);
    } else {
      _snack('Upload Failed',
          result.errorMessage ?? 'Could not upload photo.', Colors.red);
    }
  }

  Future<void> _delete() async {
    Get.back();
    await pc.deleteImage();
    _snack('Photo Removed', 'Your profile photo has been removed.', Colors.red);
  }

  void _snack(String title, String msg, Color color) =>
      Get.snackbar(title, msg,
          backgroundColor: color,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          borderRadius: 12,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),
        Text('Profile Photo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 20),
        _tile(context, Icons.photo_library_outlined, 'Choose from Gallery',
            () => _pick(ImageSource.gallery)),
        const SizedBox(height: 10),
        _tile(context, Icons.camera_alt_outlined, 'Take a Photo',
            () => _pick(ImageSource.camera)),
        if (!pc.isDeleted) ...[
          const SizedBox(height: 10),
          _tile(context, Icons.delete_outline_rounded, 'Remove Photo', _delete,
              color: Colors.red),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: const Text('Cancel'),
          ),
        ),
      ]),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label,
      VoidCallback onTap, {Color? color}) {
    final c = color ?? _green;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: c.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600, color: c)),
        ]),
      ),
    );
  }
}
