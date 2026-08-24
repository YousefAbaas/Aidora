import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/net_image.dart';
import '../widgets/org_initial_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/organization_api_model.dart';
import '../services/organization_service.dart';
import '../services/profile_api_service.dart';
import '../utils/icon_mapper.dart';
import 'complete_profile_screen.dart';
import 'service_request_screen.dart';

/// GuestOrgDetailsScreen
/// showAddButton=true  â†’ refugee home view (shows + per service)
/// showAddButton=false â†’ public / org-list view (no + buttons)
class GuestOrgDetailsScreen extends StatefulWidget {
  final int orgId;
  final bool showAddButton;
  const GuestOrgDetailsScreen({
    super.key,
    required this.orgId,
    this.showAddButton = false,
  });

  @override
  State<GuestOrgDetailsScreen> createState() => _GuestOrgDetailsScreenState();
}

class _GuestOrgDetailsScreenState extends State<GuestOrgDetailsScreen> {
  static const Color _green = Color(0xFF2C5F4F);

  final OrganizationService _service = OrganizationService.effective;

  OrganizationDetailModel? _org;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await _service.fetchOrganizationDetail(widget.orgId);
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _org = result.organization;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // â”€â”€ Tap "+" next to a service â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _requestService(OrgService svc) async {
    // Guard: service must have a valid ID (id=0 means Django didn't return it)
    if (svc.id == 0) {
      Get.snackbar(
        'Error',
        'Service ID not available. Please refresh and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    // 1. Check profile completion
    final me = await ProfileApiService.instance.checkMe();
    if (!me.isSuccess || !me.profileCompleted) {
      if (!mounted) return;
      final done = await Get.to(
        () => const CompleteProfileScreen(returnOnComplete: true),
        transition: Transition.cupertino,
      );
      if (done != true) return;
    }

    // 2. Navigate to ServiceRequestScreen with both IDs
    if (!mounted) return;
    Get.to(
      () => ServiceRequestScreen(
        orgId: widget.orgId,
        serviceId: svc.id,
        serviceName: svc.name,
        orgName: _org?.name ?? '',
      ),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _org?.name ?? 'Organization',
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C5F4F)));
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
                style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ),
      );
    }

    final org = _org!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // â”€â”€ Logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.grey[100], shape: BoxShape.circle),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: NetImage(
                    url: org.logo,
                    fit: BoxFit.contain,
                    width: 80,
                    height: 80,
                    fallback: OrgInitialAvatar(name: org.name, size: 80),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(org.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(org.title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ]),
        ),

        // â”€â”€ About â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _section(
          title: 'About Mission',
          child: Text(org.about,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[700], height: 1.5)),
        ),
        const SizedBox(height: 24),

        // â”€â”€ Target Groups â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _section(
          title: 'Target Groups',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: org.targetGroups
                .map((g) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(g,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),

        // â”€â”€ Services (with optional + button) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _section(
          title: 'Services Provided',
          trailing: Text('${org.services.length} Key Areas',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600)),
          child: Column(
            children: org.services.map((svc) {
              final icon = IconMapper.get(svc.icon);
              final color = IconMapper.getColor(svc.icon);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(svc.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(svc.description,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    )),
                    // "+" button â€” refugee home only
                    if (widget.showAddButton) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _requestService(svc),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // â”€â”€ Impact Images â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (org.impactImage1 != null || org.impactImage2 != null)
          _section(
            title: 'Our Impact',
            child: Row(children: [
              if (org.impactImage1 != null)
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetImage(
                    url: org.impactImage1!,
                    height: 150,
                    fit: BoxFit.cover,
                    fallback: Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50)),
                  ),
                )),
              if (org.impactImage1 != null && org.impactImage2 != null)
                const SizedBox(width: 12),
              if (org.impactImage2 != null)
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetImage(
                    url: org.impactImage2!,
                    height: 150,
                    fit: BoxFit.cover,
                    fallback: Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50)),
                  ),
                )),
            ]),
          ),
        const SizedBox(height: 32),

        // â”€â”€ Contact â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            if (org.officialWebsite != null)
              _contactRow(Icons.language, Colors.blue[50]!, Colors.blue,
                  'Official Website', () => _launchUrl(org.officialWebsite)),
            if (org.contactEmail != null) ...[
              const SizedBox(height: 12),
              _contactRow(
                  Icons.email_outlined,
                  Colors.green[50]!,
                  Colors.green,
                  org.contactEmail!,
                  () => _launchUrl('mailto:${org.contactEmail}')),
            ],
          ]),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _section(
          {required String title, Widget? trailing, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (trailing != null) ...[const Spacer(), trailing],
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      );

  Widget _contactRow(IconData icon, Color bg, Color color, String label,
          VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ]),
        ),
      );
}
