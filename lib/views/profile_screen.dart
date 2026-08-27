import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../utils/app_theme.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../widgets/profile_avatar.dart';
import 'selection_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// ProfileScreen  (API-connected)
/// GET /api/auth/profile/refugee/ â†’ shows real data
/// Profile image change propagates to all screens via ProfileController.
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg = Color(0xFFF5F3ED);

  final ProfileController _pc = ProfileController.to;

  @override
  void initState() {
    super.initState();
    _pc.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final profile = _pc.profile;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(children: [
                Text('profile'.tr,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.textColor)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.settings_rounded,
                      color: context.textColor, size: 22),
                  onPressed: () => Get.to(() => const SettingsScreen(),
                      transition: Transition.cupertino),
                  tooltip: 'Settings',
                ),
                Obx(() {
                  final count = NotificationService.to.unreadCount.value;
                  return Stack(clipBehavior: Clip.none, children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Get.to(() => const NotificationsScreen(),
                          transition: Transition.cupertino),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: Color(0xFFE74C3C), shape: BoxShape.circle),
                          child: Center(
                            child: Text(count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ]);
                }),
              ]),

              const SizedBox(height: 24),

              // â”€â”€ Loading / Error â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_pc.profileLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: _green),
                ))
              else if (_pc.profileError.isNotEmpty && profile == null)
                _errorWidget()
              else ...[
                // â”€â”€ Avatar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Center(
                    child: ProfileAvatar(
                  size: 120,
                  borderWidth: 3,
                  showEditBadge: true,
                )),
                const SizedBox(height: 14),

                // â”€â”€ Name + ID â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Center(
                  child: Column(children: [
                    Text(profile?.fullName ?? 'User',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E3C))),
                    const SizedBox(height: 6),
                    if (profile?.refugeeId.isNotEmpty == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(profile!.refugeeId,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ),
                    const SizedBox(height: 8),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.touch_app_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('Tap photo to change or remove',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ]),
                  ]),
                ),

                const SizedBox(height: 24),

                // â”€â”€ Location â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _card(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.location_on, 'Current Location'),
                    const SizedBox(height: 12),

                    // â”€â”€ Map image â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'img/map_location.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9E8E3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_rounded,
                                      size: 44, color: Colors.grey[400]),
                                  const SizedBox(height: 6),
                                  Text('Map Preview',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // navigate icon top-right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4)
                                ]),
                            child: const Icon(Icons.navigation_rounded,
                                color: _green, size: 16),
                          ),
                        ),
                        // "Area Currently Safe" badge bottom-left
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.green[600],
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              const Text('Area Currently Safe',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // â”€â”€ Location text row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!)),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.1),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.location_on,
                              color: _green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile?.location ?? 'â€”',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            if (profile?.sectorName.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(profile!.sectorName,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500])),
                            ],
                          ],
                        )),
                      ]),
                    ),
                  ],
                )),

                const SizedBox(height: 16),

                // â”€â”€ Household â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _card(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.people, 'Household'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: _hhCard('${profile?.childrenCount ?? 0}',
                              'Children', Icons.child_care, Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _hhCard('${profile?.elderlyCount ?? 0}',
                              'Elderly', Icons.elderly, Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _hhCard('${profile?.disabledCount ?? 0}',
                              'Disabled', Icons.accessible, Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _hhCard('${profile?.womenCount ?? 0}', 'Women',
                              Icons.woman, Colors.pink)),
                    ]),
                  ],
                )),

                const SizedBox(height: 16),

                // â”€â”€ Total family + Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        const Icon(Icons.people, color: _green, size: 32),
                        const SizedBox(height: 8),
                        Text('${profile?.totalFamilyMembers ?? 0}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _green)),
                        Text('total_family'.tr,
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 32),
                            SizedBox(height: 8),
                            Text('log_out'.tr,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
              ],
            ],
          );
        }),
      ),
    );
  }

  // â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'log_out'.tr,
      ),
      content: Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'cancel'.tr,
            )),
        ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(
              'log_out'.tr,
            )),
      ],
    ));
    if (confirmed == true) {
      await AuthService.instance.logout();
      Get.offAll(() => const SelectionScreen(), transition: Transition.fadeIn);
    }
  }

  // â”€â”€ Error widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _errorWidget() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(_pc.profileError,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF5A5A5A))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pc.loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'retry'.tr,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ]),
        ),
      );

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _card({required Widget child}) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: child);

  Widget _sectionHeader(IconData icon, String title) => Row(children: [
        Icon(icon, color: _green),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]);

  Widget _hhCard(String count, String label, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(count,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}
