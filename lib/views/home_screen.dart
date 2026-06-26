import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/org_initial_avatar.dart';

import '../models/organization_api_model.dart';
import '../models/service_model.dart';
import '../services/organization_service.dart';
import '../services/services_api_service.dart';
import '../widgets/ai_search_bar.dart';
import '../widgets/profile_avatar.dart';
import '../services/notification_service.dart';
import '../controllers/profile_controller.dart';
import '../utils/app_theme.dart';
import '../utils/icon_mapper.dart';

import 'guest_org_details_screen.dart';
import 'notifications_screen.dart';
import 'submit_new_request_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HomeScreen  (API-connected)
/// • Loads organizations from GET /api/organizations/cards/
/// • Filter button loads services from GET /api/organizations/services/
///   then filters via GET /api/organizations/filter/<service_type>/
/// • "View Details" → GuestOrgDetailsScreen(orgId)
/// • "Request Help" → SubmitNewRequestScreen
/// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bg    = Color(0xFFF5F3ED);
  static const Color _green = Color(0xFF2C5F4F);
  static const Color _blue  = Color(0xFF1565C0);

  final OrganizationService  _orgSvc  = OrganizationService.instance;
  final ServicesApiService   _svcSvc  = ServicesApiService.instance;

  List<OrganizationCardModel> _orgs    = [];
  bool   _loading = true;
  String? _error;
  bool   _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _loadOrgs();
  }

  // ── Load all orgs ──────────────────────────────────────────────────────────
  Future<void> _loadOrgs() async {
    setState(() { _loading = true; _error = null; _isFiltered = false; });
    final r = await _orgSvc.fetchOrganizations();
    if (!mounted) return;
    if (r.isSuccess) {
      setState(() { _orgs = r.organizations; _loading = false; });
    } else {
      setState(() { _error = r.errorMessage; _loading = false; });
    }
  }

  // ── Open service filter sheet then filter orgs ─────────────────────────────
  Future<void> _openFilter() async {
    // 1. fetch services from API
    final svcResult = await _svcSvc.fetchServices();
    if (!mounted) return;

    if (!svcResult.isSuccess || svcResult.services.isEmpty) {
      Get.snackbar('Error', svcResult.errorMessage ?? 'Failed to load filters.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[50],
          colorText: Colors.red[800],
          margin: const EdgeInsets.all(12), borderRadius: 12);
      return;
    }

    // 2. Show bottom sheet with real service types
    final selected = await showModalBottomSheet<ServiceModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ServiceFilterSheet(services: svcResult.services),
    );
    if (selected == null || !mounted) return;

    // 3. Filter orgs by selected service_type
    setState(() { _loading = true; _error = null; });
    final filterResult = await _orgSvc.fetchFilteredOrganizations(selected.serviceType);
    if (!mounted) return;

    if (filterResult.isSuccess) {
      setState(() {
        _orgs      = filterResult.organizations;
        _loading   = false;
        _isFiltered = true;
      });
      if (_orgs.isEmpty) {
        Get.snackbar('No Results',
            'No organizations found for "${selected.serviceType}".',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange[50],
            colorText: Colors.orange[800],
            margin: const EdgeInsets.all(12), borderRadius: 12);
        _loadOrgs();
      } else {
        Get.snackbar(
          selected.serviceType,
          '${_orgs.length} organization(s) found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: _green.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12), borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      setState(() { _error = filterResult.errorMessage; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                const ProfileAvatar(size: 46, borderColor: Color(0xFF2C5F4F)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('welcome_back'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    Obx(() {
                      final pc = Get.find<ProfileController>();
                      final name = pc.profile?.fullName ?? pc.displayName;
                      return Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E3C)));
                    }),
                  ],
                ),
                const Spacer(),
                Obx(() {
                  final count = NotificationService.to.unreadCount.value;
                  return Stack(clipBehavior: Clip.none, children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Color(0xFF2C3E3C)),
                      onPressed: () => Get.to(
                          () => const NotificationsScreen(),
                          transition: Transition.cupertino),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6, top: 6,
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                              color: Color(0xFFE74C3C), shape: BoxShape.circle),
                          child: Center(
                            child: Text(count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ]);
                }),
              ]),
            ),

            // ── Title ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text('Supporting Organizations\nfor the Application',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: _green, height: 1.3)),
            ),

            // ── AI Search + Filter ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiSearchBar(
                isFiltered: _isFiltered,
                onFilterTap: _openFilter,
                onServiceDetected: (serviceType) async {
                  setState(() { _loading = true; _error = null; _isFiltered = true; });
                  final result = await _orgSvc.fetchFilteredOrganizations(serviceType);
                  if (!mounted) return;
                  if (result.isSuccess) {
                    setState(() { _orgs = result.organizations; _loading = false; });
                  } else {
                    setState(() { _error = result.errorMessage; _loading = false; });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Content ───────────────────────────────────────────────────
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF5A5A5A), fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadOrgs,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr,),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _orgs.length,
      itemBuilder: (_, i) => _OrgCard(org: _orgs[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Org Card
// ─────────────────────────────────────────────────────────────────────────────
class _OrgCard extends StatelessWidget {
  final OrganizationCardModel org;
  static const Color _blue  = Color(0xFF1565C0);
  static const Color _green = Color(0xFF2C5F4F);
  const _OrgCard({required this.org});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Logo
        Container(
          width: 52, height: 52, padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
          child: Image.asset(
            'img/org_${_orgKey(org.name)}.png',
            fit: BoxFit.contain,
            width: 40, height: 40,
            errorBuilder: (_, __, ___) => OrgInitialAvatar(name: org.name, size: 40),
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(org.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: _blue)),
              const SizedBox(height: 3),
              const Text('Humanitarian Organization',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _chip(
              icon: Icons.add_circle_outline, label: 'request_help'.tr,
              bg: const Color(0xFFE8F5E9), fg: _green,
              onTap: () => Get.to(
                  () => SubmitNewRequestScreen(orgId: org.id, orgName: org.name),
                  transition: Transition.cupertino),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () => Get.to(
                  () => GuestOrgDetailsScreen(orgId: org.id, showAddButton: true),
                  transition: Transition.cupertino),
              style: TextButton.styleFrom(
                foregroundColor: _blue,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('view_details'.tr,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Icon(Icons.arrow_forward_ios_rounded, size: 11),
              ]),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _chip({required IconData icon, required String label,
      required Color bg, required Color fg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Filter Bottom Sheet (loads from API)
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceFilterSheet extends StatelessWidget {
  final List<ServiceModel> services;
  const _ServiceFilterSheet({required this.services});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Filter by Service',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E28))),
            const SizedBox(height: 12),
            // Scrollable grid — never overflows
            Expanded(
              child: GridView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.9,
                  crossAxisSpacing: 10, mainAxisSpacing: 10,
                ),
                itemCount: services.length,
                itemBuilder: (_, i) {
                  final svc   = services[i];
                  final icon  = IconMapper.get(svc.icon);
                  final color = IconMapper.getColor(svc.icon);
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, svc),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: color, size: 26),
                          const SizedBox(height: 5),
                          Text(svc.serviceType,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: color)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts org name to local asset key
  String _orgKey(String name) {
    final s = name.toLowerCase();
    if (s.contains('unicef'))                       return 'unicef';
    if (s.contains('intersos'))                     return 'intersos';
    if (s.contains('wfp') || s.contains('food pr')) return 'wfp';
    if (s.contains('unhcr'))                        return 'unhcr';
    if (s.contains('who') || s.contains('health or')) return 'who';
    if (s.contains('red') && s.contains('crescent')) return 'red_crescent';
    return s.replaceAll(' ', '_');
  }
}
