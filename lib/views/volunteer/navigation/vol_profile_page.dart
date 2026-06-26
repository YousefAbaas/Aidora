import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/controllers/vol_controller.dart';
import 'package:aidora/widgets/vol_avatar.dart';
import 'package:aidora/services/api_constants.dart';
import 'package:aidora/services/api_service.dart';
import 'package:aidora/services/auth_storage.dart';
import 'package:aidora/views/selection_screen.dart';
import 'package:aidora/services/profile_api_service.dart';
import 'package:aidora/utils/image_url_helper.dart';
import 'package:aidora/widgets/net_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<StatefulWidget> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final FormController controller = Get.find();
  final ImagePicker    _picker    = ImagePicker();

  int    _volunteerId = 0;
  String? _profileImageUrl;   // network URL from API
  Uint8List? _pickedBytes;    // local preview on web
  String?    _pickedPath;     // local preview on native

  static const Color _green = Color(0xFF2C5F4F);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final res = await ApiService.instance.get(
      ApiConstants.volunteerProfile,
      requiresAuth: true,
    );
    if (!mounted) return;
    setState(() {
      var d = res.data as Map<String, dynamic>? ?? {};
      controller.userName.value   = d['full_name']           ?? '';
      controller.joinDate.value   = d['join_date']           ?? '';
      controller.tasks.value      = (d['tasks_count'] as num?)?.toInt()  ?? 0;
      controller.points.value     = (d['points']     as num?)?.toInt()  ?? 0;
      controller.experiences.value = d['previous_experience'] ?? '';
      if (d['skills']    != null) controller.skills.assignAll(List<String>.from(d['skills']));
      if (d['languages'] != null) controller.language.assignAll(List<String>.from(d['languages']));
      _volunteerId = (d['id'] ?? d['volunteer_id'] ?? 0 as num).toInt();
      // Profile image URL from API
      var rawImg = d['profile_image']?.toString();
      _profileImageUrl = rawImg != null && rawImg.isNotEmpty
          ? ImageUrlHelper.fix(rawImg) : null;
      // Sync to FormController for global reactivity
      controller.userImage.value = _profileImageUrl ?? '';
      // Sync VolController for reactive avatar across screens
      if (Get.isRegistered<VolController>()) VolController.to.setImage(_profileImageUrl ?? '');
    });
  }

  // ── Pick profile image ────────────────────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    // Immediate local preview
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() { _pickedBytes = bytes; });
    } else {
      if (mounted) setState(() { _pickedPath = file.path; });
    }

    // Upload using ProfileApiService (PATCH /api/auth/profile/upload-image/)
    final res = await ProfileApiService.instance.uploadProfileImageXFile(file);
    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _profileImageUrl = res.imageUrl;
        _pickedBytes = null; _pickedPath = null;
      });
      // Sync to FormController so home page & all screens react instantly
      controller.userImage.value = res.imageUrl ?? '';
      // Sync VolController reactive avatar
      if (Get.isRegistered<VolController>()) VolController.to.setImage(res.imageUrl ?? '');
      Get.snackbar('Updated', 'Profile photo uploaded.',
          backgroundColor: _green, colorText: Colors.white,
          snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(12));
    } else {
      Get.snackbar('Error', res.errorMessage ?? 'Upload failed.',
          backgroundColor: Colors.red[50], colorText: Colors.red[800],
          snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(12));
    }
  }

  // ── Show QR code ──────────────────────────────────────────────────────────
  Future<void> _showQrCode() async {
    if (_volunteerId == 0) {
      Get.snackbar('Error', 'Could not load volunteer ID',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[50], colorText: Colors.red[800]);
      return;
    }
    Get.dialog(const Center(child: CircularProgressIndicator()));
    final res = await ApiService.instance.get(
      ApiConstants.volunteerQr(_volunteerId),
      requiresAuth: true,
    );
    Get.back();
    if (!res.isSuccess) {
      Get.snackbar('Error', res.errorMessage ?? 'Failed to load QR',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[50], colorText: Colors.red[800]);
      return;
    }
    final displayName = res.data['display_name'] ?? controller.userName.value;
    final qrB64       = res.data['qr_image_base64'] as String? ?? '';
    Get.dialog(_QrDialog(displayName: displayName, qrBase64: qrB64));
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Log Out'),
        ),
      ],
    ));
    if (confirmed != true) return;

    await ApiService.instance.post(
      ApiConstants.logout,
      requiresAuth: true,
      body: {'refresh': AuthStorage.getRefreshToken() ?? ''},
    );
    await AuthStorage.clear();
    Get.offAll(() => const SelectionScreen(), transition: Transition.fadeIn);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              onPressed: _showQrCode,
              tooltip: 'Show QR Code',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _profileInfo(),
          _stats(),
          _skills(),
          _experience(),
          _logoutBtn(),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  // ── Avatar with upload ────────────────────────────────────────────────────
  Widget _profileInfo() {
    return Column(children: [
      const SizedBox(height: 24),
      GestureDetector(
        onTap: _pickAndUpload,
        child: Stack(clipBehavior: Clip.none, children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: _avatarWidget(),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _green, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Obx(() => Text(controller.userName.value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      Obx(() => Text(
          '${controller.role.value} • ${controller.joinDate.value}',
          style: const TextStyle(color: Color(0xFF27AE60)))),
      const SizedBox(height: 8),
    ]);
  }

  Widget _avatarWidget() {
    // 1. Local preview (just picked)
    if (_pickedBytes != null) {
      return Image.memory(_pickedBytes!, fit: BoxFit.cover, width: 100, height: 100);
    }
    if (_pickedPath != null && !kIsWeb) {
      return NetImage(url: _pickedPath, fit: BoxFit.cover, width: 100, height: 100);
    }
    // 2. Server image
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetImage(
        url: _profileImageUrl, fit: BoxFit.cover,
        width: 100, height: 100, bustCache: true,
      );
    }
    // 3. Default
    return const Icon(Icons.person_rounded, size: 56, color: Colors.grey);
  }

  Widget _stats() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(child: _statCard(label: 'Tasks',  value: controller.tasks,
          color: Colors.blue.shade50,   textColor: Colors.blue)),
      const SizedBox(width: 10),
      Expanded(child: _statCard(label: 'Points', value: controller.points,
          color: Colors.orange.shade50, textColor: Colors.orange)),
    ]),
  );

  Widget _statCard({required String label, required RxInt value,
      required Color color, required Color textColor}) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(label),
          const SizedBox(height: 8),
          Obx(() => Text(value.value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: textColor))),
        ]),
      );

  Widget _skills() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      const Text('Skills & Badges',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Obx(() => Wrap(spacing: 10,
          children: controller.skills.map((e) => Chip(
            label: Text(e),
            backgroundColor: Colors.green.shade50,
          )).toList())),
      const SizedBox(height: 10),
      Obx(() => Wrap(spacing: 10,
          children: controller.language.map((e) => Chip(
            label: Text(e),
            backgroundColor: Colors.teal.shade50,
          )).toList())),
    ]),
  );

  Widget _experience() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      const Align(alignment: Alignment.centerLeft,
          child: Text('Previous experience',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Obx(() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.volunteer_activism, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(controller.experiences.value)),
        ]),
      )),
    ]),
  );

  Widget _logoutBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50, foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.logout_rounded, size: 20),
        SizedBox(width: 8),
        Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── QR Dialog ─────────────────────────────────────────────────────────────────
class _QrDialog extends StatelessWidget {
  final String displayName;
  final String qrBase64;
  const _QrDialog({required this.displayName, required this.qrBase64});

  @override
  Widget build(BuildContext context) {
    Uint8List? imgBytes;
    if (qrBase64.isNotEmpty) {
      try {
        final b64 = qrBase64.contains(',') ? qrBase64.split(',').last : qrBase64;
        imgBytes = base64Decode(b64);
      } catch (_) {}
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(displayName, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 20),
          if (imgBytes != null)
            ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.memory(imgBytes, width: 220, height: 220))
          else
            Container(
              width: 220, height: 220,
              decoration: BoxDecoration(color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5F4F), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Close'),
          ),
        ]),
      ),
    );
  }
}
