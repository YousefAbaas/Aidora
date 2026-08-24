import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/requests_controller.dart';
import '../services/api_constants.dart';
import '../services/api_service.dart';
import '../services/profile_api_service.dart';
import '../utils/icon_mapper.dart';
import 'complete_profile_screen.dart';
import 'my_requests_screen.dart';
import 'requests_dashboard_screen.dart';

/// SubmitNewRequestScreen
///
/// Step 1: GET /api/requests/<orgId>/services/ → service list
/// Step 2: User fills form
/// Step 3: POST /api/requests/<orgId>/createrequest/
///   body: {service, family_members, urgency_level, description, location}
///   success: {message: "Request submitted successfully"}
class SubmitNewRequestScreen extends StatefulWidget {
  final int?    orgId;
  final String? orgName;

  const SubmitNewRequestScreen({
    super.key,
    this.orgId,
    this.orgName,
  });

  @override
  State<SubmitNewRequestScreen> createState() => _SubmitNewRequestScreenState();
}

class _SubmitNewRequestScreenState extends State<SubmitNewRequestScreen> {
  static const Color _green  = Color(0xFF2C5F4F);
  static const Color _bg     = Color(0xFFF5F3ED);

  final _api      = ApiService.instance;
  final _descCtrl = TextEditingController();
  final _locCtrl  = TextEditingController(text: 'Al-Rimal District, Near Central Park');

  List<_OrgService> _services       = [];
  bool              _loadingServices = true;
  String?           _serviceError;

  _OrgService? _selected;
  int          _familyMembers = 4;
  String       _urgency       = 'normal';
  bool         _submitting    = false;

  static const _urgencyOptions = ['low', 'normal', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    _checkProfileThenLoad();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkProfileThenLoad() async {
    if (widget.orgId == null) {
      setState(() => _loadingServices = false);
      return;
    }
    final me = await ProfileApiService.instance.checkMe();
    if (!mounted) return;
    if (!me.isSuccess || !me.profileCompleted) {
      final done = await Get.to(
        () => const CompleteProfileScreen(returnOnComplete: true),
        transition: Transition.cupertino,
      );
      if (done != true) { Get.back(); return; }
    }
    await _loadServices();
  }

  Future<void> _loadServices() async {
    if (widget.orgId == null) return;
    setState(() { _loadingServices = true; _serviceError = null; });

    final r = await _api.get(
      ApiConstants.orgServices(widget.orgId!),
      requiresAuth: true,
    );
    if (!mounted) return;

    if (r.isSuccess) {
      try {
        final list = (r.data as List)
            .map((e) => _OrgService.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() { _services = list; _loadingServices = false; });
      } catch (e) {
        setState(() { _serviceError = 'Parse error: $e'; _loadingServices = false; });
      }
    } else {
      setState(() { _serviceError = r.errorMessage; _loadingServices = false; });
    }
  }

  Future<void> _submit() async {
    if (_selected == null) {
      _snack('Please select the type of aid needed.', isError: true); return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _snack('Please describe your situation.', isError: true); return;
    }
    if (_locCtrl.text.trim().isEmpty) {
      _snack('Please enter your location.', isError: true); return;
    }

    setState(() => _submitting = true);

    final r = await _api.post(
      ApiConstants.createRequest(widget.orgId!),
      requiresAuth: true,
      body: {
        'service':        _selected!.id,
        'family_members': _familyMembers,
        'urgency_level':  _urgency,
        'description':    _descCtrl.text.trim(),
        'location':       _locCtrl.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (r.isSuccess) {
      try { Get.find<RequestsController>().fetchRequests(); } catch (_) {}
      MyRequestsScreen.refresh();
      RequestsDashboardScreen.refresh();
      Get.back();
      Get.snackbar(
        'Request Submitted ✓',
        r.data is Map
            ? (r.data['message'] ?? 'Request submitted successfully')
            : 'Success',
        snackPosition: SnackPosition.TOP,
        backgroundColor: _green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } else {
      _snack(r.errorMessage ?? 'Submission failed. Try again.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) => Get.snackbar(
    isError ? 'Error' : 'Info', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red[50] : _green,
    colorText: isError ? Colors.red[800] : Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: widget.orgId == null
            ? _noOrgView()
            : _loadingServices
                ? const Center(
                    child: CircularProgressIndicator(color: _green))
                : _serviceError != null
                    ? _errorView()
                    : _body(),
      ),
    );
  }

  Widget _body() => Column(
    children: [
      // ── Header ─────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8)]),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  size: 18, color: Color(0xFF2C3E3C)),
            ),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Submit New Request',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E28))),
            Text('Fill in the details to receive aid',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
        ]),
      ),

      const SizedBox(height: 20),

      // ── Scrollable form ─────────────────────────────────────────────────
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Type of Aid Needed ──────────────────────────────────────
              _label('Type of Aid Needed'),
              const SizedBox(height: 8),
              _dropdownService(),

              const SizedBox(height: 20),

              // ── Family Members + Urgency Level ──────────────────────────
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Family counter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Family Members'),
                      const SizedBox(height: 8),
                      _familyCounter(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Urgency dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Urgency Level'),
                      const SizedBox(height: 8),
                      _urgencyDropdown(),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              // ── Description ─────────────────────────────────────────────
              _label('Brief Description of Need'),
              const SizedBox(height: 8),
              _textBox(
                controller: _descCtrl,
                hint: 'Please describe your situation and specific needs here...',
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // ── Location ────────────────────────────────────────────────
              _label('Confirm Location'),
              const SizedBox(height: 8),
              _locationBox(),

              const SizedBox(height: 32),

              // ── Submit button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: _green.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit Request',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By submitting, you agree that the information provided is\naccurate and true.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400], height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // ── Service dropdown ───────────────────────────────────────────────────────
  Widget _dropdownService() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2))]),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<_OrgService>(
        value: _selected,
        isExpanded: true,
        hint: Text('Select aid type',
            style: TextStyle(color: Colors.grey[400], fontSize: 15)),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[500], size: 24),
        items: _services.map((s) {
          final icon  = IconMapper.get(s.icon);
          final color = IconMapper.getColor(s.icon);
          return DropdownMenuItem<_OrgService>(
            value: s,
            child: Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(s.name, style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w500)),
            ]),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selected = v),
      ),
    ),
  );

  // ── Family counter ─────────────────────────────────────────────────────────
  Widget _familyCounter() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2))]),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () { if (_familyMembers > 1) setState(() => _familyMembers--); },
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.remove_rounded, size: 18, color: Color(0xFF2C3E3C)),
        ),
      ),
      Text('$_familyMembers',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E28))),
      GestureDetector(
        onTap: () => setState(() => _familyMembers++),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF2C3E3C)),
        ),
      ),
    ]),
  );

  // ── Urgency dropdown ───────────────────────────────────────────────────────
  Widget _urgencyDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2))]),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _urgency,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[500], size: 22),
        items: _urgencyOptions.map((u) => DropdownMenuItem(
          value: u,
          child: Text(u[0].toUpperCase() + u.substring(1),
              style: const TextStyle(fontSize: 14)),
        )).toList(),
        onChanged: (v) => setState(() => _urgency = v!),
      ),
    ),
  );

  // ── Text box ───────────────────────────────────────────────────────────────
  Widget _textBox({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6, offset: const Offset(0, 2))]),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      );

  // ── Location box ───────────────────────────────────────────────────────────
  Widget _locationBox() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.location_on_rounded,
            color: Color(0xFFFF8C00), size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Current Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E28))),
          const SizedBox(height: 2),
          TextField(
            controller: _locCtrl,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ]),
      ),
      Icon(Icons.edit_rounded, color: Colors.grey[400], size: 18),
    ]),
  );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E3C)));

  // ── No org selected ────────────────────────────────────────────────────────
  Widget _noOrgView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.volunteer_activism_rounded, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 20),
        const Text('No Organization Selected',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Go to the Home tab and tap "Request Help"\nnext to an organization.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
          child: const Text('Go Back'),
        ),
      ]),
    ),
  );

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(_serviceError!, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _loadServices,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _OrgService {
  final int    id;
  final String name;
  final String icon;
  const _OrgService({required this.id, required this.name, required this.icon});
  factory _OrgService.fromJson(Map<String, dynamic> j) => _OrgService(
    id:   (j['id'] as num).toInt(),
    name: j['name'] as String,
    icon: j['icon'] as String? ?? 'help_outline',
  );
  @override bool operator ==(Object other) => other is _OrgService && id == other.id;
  @override int  get hashCode => id.hashCode;
}
