import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart' show routeObserver;
import '../models/organization_api_model.dart';
import '../services/organization_service.dart';
import '../widgets/ai_search_bar.dart';
import '../widgets/org_initial_avatar.dart';
import 'filter_screen.dart';
import 'guest_org_details_screen.dart';
import 'login_screen.dart';
/// ─────────────────────────────────────────────────────────────────────────────
/// OrganizationsListScreen  (API-connected)
/// Fetches organizations from Django backend.
/// Filter button calls /api/organizations/filter/<type>/ directly.
/// ─────────────────────────────────────────────────────────────────────────────
class OrganizationsListScreen extends StatefulWidget {
  const OrganizationsListScreen({super.key});
  @override
  State<OrganizationsListScreen> createState() =>
      _OrganizationsListScreenState();
}
class _OrganizationsListScreenState extends State<OrganizationsListScreen>
    with RouteAware {
  static const Color _green = Color(0xFF2C5F4F);
  final OrganizationService _service = OrganizationService.effective;
  List<OrganizationCardModel> _organizations = [];
  bool _isLoading = true;
  bool _isFiltered = false;
  String? _errorMsg;
  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  /// Called when a route above this one is popped — reset filter
  @override
  void didPopNext() {
    if (_isFiltered) {
      _loadOrganizations();
    }
  }
  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await _service.fetchOrganizations();
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _organizations = result.organizations;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg = result.errorMessage;
        _isLoading = false;
      });
    }
  }
  Future<void> _openFilterAndApply() async {
    final selected = await Get.to(() => const FilterScreen(),
        transition: Transition.downToUp);
    if (selected == null || selected is! List || selected.isEmpty) return;
    final serviceType = selected[0] as String;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await _service.fetchFilteredOrganizations(serviceType);
    if (!mounted) return;
    if (result.isSuccess) {
      if (result.organizations.isEmpty) {
        Get.snackbar('No Results', 'No organizations found for this category.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.15),
            colorText: Colors.orange,
            margin: const EdgeInsets.all(16),
            borderRadius: 12);
        await _loadOrganizations();
      } else {
        setState(() {
          _organizations = result.organizations;
          _isLoading = false;
          _isFiltered = true;
        });
        final labels = {
          'protection': 'Child Protection',
          'education': 'Education',
          'water': 'Water & Sanitation',
          'health': 'Healthcare',
          'food': 'Food Assistance',
          'shelter': 'Shelter',
          'emergency': 'Emergency',
          'logistics': 'Logistics',
          'vaccination': 'Vaccination',
          'legal': 'Legal Assistance',
        };
        Get.snackbar(
          labels[serviceType] ?? serviceType,
          '${result.organizations.length} organization(s) found  •  Pull to refresh',
          snackPosition: SnackPosition.TOP,
          backgroundColor: _green.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      setState(() {
        _errorMsg = result.errorMessage;
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFiltered) {
          _loadOrganizations();
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF2C3E3C), size: 22),
                    onPressed: () {
                      if (_isFiltered) {
                        _loadOrganizations();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded,
                        color: Color(0xFF2C3E3C), size: 22),
                    onPressed: _loadOrganizations,
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 16, 16),
                child: Text('Supporting Organization\nfor the Application',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _green,
                        height: 1.25)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AiSearchBar(
                  isFiltered: _isFiltered,
                  onFilterTap: _openFilterAndApply,
                  onServiceDetected: (serviceType) async {
                    setState(() {
                      _isLoading = true;
                      _errorMsg = null;
                      _isFiltered = true;
                    });
                    final result =
                    await _service.fetchFilteredOrganizations(serviceType);
                    if (!mounted) return;
                    if (result.isSuccess) {
                      setState(() {
                        _organizations = result.organizations;
                        _isLoading = false;
                      });
                    } else {
                      setState(() {
                        _errorMsg = result.errorMessage;
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ), // WillPopScope
    );
  }
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF2C5F4F)),
          SizedBox(height: 16),
          Text('Loading organizations…',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ]),
      );
    }
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF5A5A5A), fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrganizations,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'retry'.tr,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F4F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ]),
        ),
      );
    }
    if (_organizations.isEmpty) {
      return const Center(
          child: Text('No organizations found.',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      cacheExtent: 500,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _organizations.length,
      itemBuilder: (_, i) => _OrgCard(org: _organizations[i]),
    );
  }
}
class _OrgCard extends StatelessWidget {
  final OrganizationCardModel org;
  static const Color _green = Color(0xFF2C5F4F);
  const _OrgCard({required this.org});
  static const Color _blue = Color(0xFF1565C0);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _staticOrgLogo(org.id.toString()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(org.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _blue)),
                const SizedBox(height: 3),
                Text('Humanitarian Organization',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(children: [
                  _chip(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'request_help'.tr,
                    bg: const Color(0xFFE8F5E9),
                    fg: _green,
                    onTap: () => Get.to(() => const LoginScreen(),
                        transition: Transition.cupertino),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.to(
                            () => GuestOrgDetailsScreen(
                            orgId: org.id, showAddButton: false),
                        transition: Transition.cupertino),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('details'.tr,
                          style: TextStyle(
                              fontSize: 13,
                              color: _blue,
                              fontWeight: FontWeight.w700)),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: _blue),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _chip(
      {required IconData icon,
        required String label,
        required Color bg,
        required Color fg,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration:
        BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ]),
      ),
    );
  }
  /// Returns a static local asset image for the given org id/name.
  Widget _staticOrgLogo(String idOrName) {
    final key = _resolveOrgKey(idOrName);
    final path = 'img/org_$key.png';
    return Image.asset(
      path,
      width: 46,
      height: 46,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => OrgInitialAvatar(name: idOrName, size: 46),
    );
  }
  String _resolveOrgKey(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('unicef')) return 'unicef';
    if (s.contains('intersos')) return 'intersos';
    if (s.contains('wfp') || s.contains('world food')) return 'wfp';
    if (s.contains('unhcr')) return 'unhcr';
    if (s.contains('who') || s.contains('health organ')) return 'who';
    if (s.contains('red') && s.contains('crescent')) return 'red_crescent';
    return s.replaceAll(' ', '_');
  }
}
