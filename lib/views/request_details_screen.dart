import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/request_model.dart';
import '../services/requests_api_service.dart';
import '../utils/image_url_helper.dart';
import '../widgets/net_image.dart';
import 'qr_scanner_screen.dart';

/// RequestDetailsScreen
///
/// Accepts a [RequestModel] (from list). On init, fetches full details from
/// GET /api/requests/<id>/details/ and renders the rich layout (Image 2).
class RequestDetailsScreen extends StatefulWidget {
  final RequestModel request;
  const RequestDetailsScreen({super.key, required this.request});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  static const Color _darkGreen = Color(0xFF1E3A2F);
  static const Color _green     = Color(0xFF2C5F4F);

  final _svc = RequestsApiService.instance;
  RequestDetailModel? _detail;
  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.request.id.toString());
    if (id == null) {
      setState(() { _error = 'Invalid request ID'; _loading = false; });
      return;
    }
    final r = await _svc.fetchRequestDetails(id);
    if (!mounted) return;
    setState(() {
      _detail  = r.isSuccess ? r.data : null;
      _error   = r.isSuccess ? null   : r.errorMessage;
      _loading = false;
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get _status => _detail?.status ?? widget.request.status;

  Color get _statusColor {
    switch (_status) {
      case 'completed': return const Color(0xFF27AE60);
      case 'approved':  return const Color(0xFF2980B9);
      case 'pending':   return const Color(0xFFE67E22);
      case 'rejected':  return const Color(0xFFE74C3C);
      default:          return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (_status) {
      case 'completed': return 'Completed - Ready for Pickup';
      case 'approved':  return 'Approved · Ready for Pickup';
      case 'pending':   return 'Pending Review';
      case 'rejected':  return 'Request Rejected';
      default:          return _status;
    }
  }

  IconData get _serviceIcon {
    final t = (_detail?.serviceName ?? widget.request.serviceName).toLowerCase();
    if (t.contains('food'))     return Icons.restaurant_rounded;
    if (t.contains('medical') || t.contains('health')) return Icons.medical_services_rounded;
    if (t.contains('cloth'))    return Icons.checkroom_rounded;
    if (t.contains('cash'))     return Icons.payments_rounded;
    if (t.contains('hygiene'))  return Icons.soap_rounded;
    if (t.contains('child') || t.contains('protect')) return Icons.shield_rounded;
    if (t.contains('educat'))   return Icons.school_rounded;
    if (t.contains('psycho') || t.contains('mental')) return Icons.psychology_rounded;
    if (t.contains('water'))    return Icons.water_drop_rounded;
    if (t.contains('shelter'))  return Icons.home_rounded;
    if (t.contains('legal'))    return Icons.gavel_rounded;
    return Icons.volunteer_activism_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE5),
      body: _loading
          ? _loadingView()
          : _error != null
              ? _errorView()
              : _body(),
    );
  }

  Widget _loadingView() => const Center(
    child: CircularProgressIndicator(color: Color(0xFF2C5F4F)),
  );

  Widget _errorView() => Scaffold(
    backgroundColor: const Color(0xFFF0EDE5),
    appBar: AppBar(
      backgroundColor: _darkGreen,
      foregroundColor: Colors.white,
      title: const Text('Request Details'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Get.back(),
      ),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _green, foregroundColor: Colors.white),
          ),
        ]),
      ),
    ),
  );

  Widget _body() {
    final d = _detail!;
    final logoUrl = d.organizationLogo != null
        ? ImageUrlHelper.fix(d.organizationLogo!)
        : null;

    return CustomScrollView(
      slivers: [
        // ── Hero AppBar ─────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: _darkGreen,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: const Text('Request Details',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 20)),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              // Background image — use network org logo or fallback color
              logoUrl != null && logoUrl.isNotEmpty
                  ? NetImage(
                      url: logoUrl,
                      fit: BoxFit.cover,
                      fallback: Container(color: _darkGreen),
                    )
                  : Container(color: _darkGreen),
              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x441E3A2F), Color(0xBB1E3A2F), Color(0xFF1E3A2F)],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              // Org badge + service name
              Positioned(left: 20, right: 20, bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (logoUrl != null && logoUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: NetImage(url: logoUrl, width: 18, height: 18,
                                fit: BoxFit.contain,
                                fallback: const SizedBox.shrink()),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(d.organizationName,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Text(d.serviceName,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 24, fontWeight: FontWeight.w800,
                            height: 1.1)),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + Reference row (Image 2 layout)
                _statusRefRow(d),
                const SizedBox(height: 16),

                // Aid Type + Suffices For cards (Image 2)
                Row(children: [
                  Expanded(child: _statCard(
                    icon: _serviceIcon,
                    iconColor: _green,
                    label: 'Aid Type',
                    value: d.serviceType.isNotEmpty ? d.serviceType : d.serviceName,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(
                    icon: Icons.people_rounded,
                    iconColor: const Color(0xFF1565C0),
                    label: 'Suffices For',
                    value: d.familyMembers != null
                        ? '${d.familyMembers} ${d.familyMembers == 1 ? "Person" : "People"}'
                        : '—',
                  )),
                ]),
                const SizedBox(height: 16),

                // Schedule & Logistics (Image 2)
                _scheduleCard(d),
                const SizedBox(height: 16),

                // Reference copy card
                _refCard(d.ref),
                const SizedBox(height: 20),

                // Action button
                if (_status == 'approved') _actionBtn(
                  label: 'Scan QR Code to Collect',
                  icon: Icons.qr_code_scanner_rounded,
                  color: _green,
                  onTap: () async {
                    final res = await Get.to(
                        () => QRScannerScreen(request: widget.request),
                        transition: Transition.cupertino);
                    if (res == true) Get.back(result: true);
                  },
                ),
                if (_status == 'completed') _actionBtn(
                  label: 'Aid Successfully Received',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF27AE60),
                  onTap: null,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Status + Reference row ─────────────────────────────────────────────────
  Widget _statusRefRow(RequestDetailModel d) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      // Status
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Status',
            style: TextStyle(fontSize: 11, color: Colors.grey[500],
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(
                  color: _statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(child: Text(_statusLabel,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: _statusColor))),
        ]),
      ])),
      // Divider
      Container(width: 1, height: 40, color: Colors.grey[200],
          margin: const EdgeInsets.symmetric(horizontal: 16)),
      // Reference
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Reference',
            style: TextStyle(fontSize: 11, color: Colors.grey[500],
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(d.ref,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                color: Color(0xFF1A2E28))),
      ]),
    ]),
  );

  // ── Stat card ──────────────────────────────────────────────────────────────
  Widget _statCard({required IconData icon, required Color iconColor,
      required String label, required String value}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11,
              color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w800, color: Color(0xFF2C3E3C)),
              textAlign: TextAlign.center),
        ]),
      );

  // ── Schedule & Logistics ───────────────────────────────────────────────────
  Widget _scheduleCard(RequestDetailModel d) => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: _darkGreen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Row(children: [
          Icon(Icons.access_time_rounded, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text('Schedule & Logistics',
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          if (d.createdAt != null)
            _scheduleRow(Icons.event_available_rounded,
                _green, 'Arrival Date at Center', d.createdAt!),

          if (d.receivedAt != null) ...[
            if (d.createdAt != null) _divider(),
            _scheduleRow(Icons.schedule_rounded,
                const Color(0xFF8E44AD), 'Pickup Window', d.receivedAt!),
          ],

          if (d.sector != null && d.sector!.isNotEmpty) ...[
            _divider(),
            // Distribution Center row — matches Image 2
            Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: const Color(0xFFE67E22).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.store_rounded,
                    color: Color(0xFFE67E22), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!)),
                  child: Text(d.sector!,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E3C))),
                ),
              ),
            ]),
          ],
        ]),
      ),
    ]),
  );

  Widget _scheduleRow(IconData icon, Color color, String label, String value) =>
      Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11,
              color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: Color(0xFF2C3E3C))),
        ])),
      ]);

  Widget _divider() => Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      height: 1, color: const Color(0xFFF0EDE5));

  // ── Reference card ─────────────────────────────────────────────────────────
  Widget _refCard(String ref) => GestureDetector(
    onTap: () {
      Clipboard.setData(ClipboardData(text: ref));
      Get.snackbar('Copied', 'Reference copied',
          backgroundColor: _green, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_darkGreen, _green],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: _green.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        const Icon(Icons.tag_rounded, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reference', style: TextStyle(color: Colors.white60, fontSize: 11)),
          Text('Tap to copy', style: TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
        const Spacer(),
        Text(ref, style: const TextStyle(color: Colors.white, fontSize: 18,
            fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        const Icon(Icons.copy_rounded, color: Colors.white54, size: 18),
      ]),
    ),
  );

  // ── Action button ──────────────────────────────────────────────────────────
  Widget _actionBtn({required String label, required IconData icon,
      required Color color, required VoidCallback? onTap}) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap != null ? color : Colors.grey[300],
            foregroundColor: onTap != null ? Colors.white : Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            elevation: onTap != null ? 4 : 0,
          ),
        ),
      );
}
