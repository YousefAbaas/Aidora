import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/requests_api_service.dart';
import '../controllers/requests_controller.dart';
import '../utils/app_theme.dart';
import 'my_requests_screen.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// ServiceRequestScreen
///
/// Flow:
///  1. On open: GET /api/requests/org/<orgId>/services/<serviceId>/request/
///     â†’ shows service name + description
///  2. User fills: family_members, description, location
///  3. POST same endpoint
///     success â†’ {message, request_id} â†’ back with success snackbar
///     profile incomplete â†’ {detail: "You must complete your profile first."}
///       â†’ should not happen (caller checks), but shown as error
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class ServiceRequestScreen extends StatefulWidget {
  final int orgId;
  final int serviceId;
  final String serviceName;
  final String orgName;

  const ServiceRequestScreen({
    super.key,
    required this.orgId,
    required this.serviceId,
    required this.serviceName,
    required this.orgName,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  static const Color _green = Color(0xFF2C5F4F);

  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _familyCtrl = TextEditingController(text: '1');

  final _svc = RequestsApiService.instance;

  String _serviceDesc = '';
  bool _loadingInfo = true;
  bool _submitting = false;
  String? _infoError;

  @override
  void initState() {
    super.initState();
    _fetchServiceInfo();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    _familyCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Load service info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _fetchServiceInfo() async {
    setState(() {
      _loadingInfo = true;
      _infoError = null;
    });
    final r =
        await _svc.fetchServiceRequestInfo(widget.orgId, widget.serviceId);
    if (!mounted) return;
    if (r.isSuccess) {
      setState(() {
        _serviceDesc = r.serviceDescription;
        _loadingInfo = false;
      });
    } else {
      setState(() {
        _infoError = r.errorMessage;
        _loadingInfo = false;
      });
    }
  }

  // â”€â”€ Submit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _submit() async {
    final family = _familyCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final loc = _locCtrl.text.trim();

    if (desc.isEmpty) {
      _snack('Please describe your need.', isError: true);
      return;
    }
    if (loc.isEmpty) {
      _snack('Please enter your location.', isError: true);
      return;
    }
    if (int.tryParse(family) == null || int.parse(family) < 1) {
      _snack('Enter a valid number of family members.', isError: true);
      return;
    }

    setState(() => _submitting = true);

    final r = await _svc.submitServiceRequest(
      orgId: widget.orgId,
      serviceId: widget.serviceId,
      familyMembers: family,
      description: desc,
      location: loc,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (r.isSuccess) {
      // Refresh requests so the new request shows everywhere
      try {
        Get.find<RequestsController>().fetchRequests();
      } catch (_) {}
      MyRequestsScreen.refresh();
      Get.back();
      Get.snackbar(
        'Request Sent âœ“',
        r.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: _green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } else {
      _snack(r.errorMessage ?? 'Failed to submit request.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Info',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red[50] : _green,
      colorText: isError ? Colors.red[800] : Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      maxWidth: 400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Request Service',
          style: TextStyle(
              color: context.textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: _loadingInfo
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C5F4F)))
          : _infoError != null
              ? _errorWidget()
              : _form(context),
    );
  }

  Widget _errorWidget() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(_infoError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchServiceInfo,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white),
            ),
          ]),
        ),
      );

  Widget _form(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // â”€â”€ Service info card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.volunteer_activism_rounded,
                    color: Color(0xFF2C5F4F), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.serviceName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F4F))),
                ),
              ]),
              if (_serviceDesc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_serviceDesc,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
              const SizedBox(height: 6),
              Text('Provided by ${widget.orgName}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2C5F4F),
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 24),

          // â”€â”€ Family members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _label('Number of Family Members'),
          Row(children: [
            _counterBtn(Icons.remove, () {
              final v = int.tryParse(_familyCtrl.text) ?? 1;
              if (v > 1) _familyCtrl.text = '${v - 1}';
            }),
            const SizedBox(width: 16),
            SizedBox(
              width: 56,
              child: TextField(
                controller: _familyCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _counterBtn(Icons.add, () {
              final v = int.tryParse(_familyCtrl.text) ?? 1;
              _familyCtrl.text = '${v + 1}';
            }),
          ]),
          const SizedBox(height: 20),

          // â”€â”€ Description â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _label('Describe your need'),
          _inputBox(
            controller: _descCtrl,
            hint: 'e.g. I need educational support for my children',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // â”€â”€ Location â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _label('Your location'),
          _inputBox(
            controller: _locCtrl,
            hint: 'City, district, or camp name',
            maxLines: 1,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 32),

          // â”€â”€ Submit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: _green.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Send Request',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A3A3A))),
      );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey[500], size: 20)
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      );

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _green, size: 20),
        ),
      );
}
