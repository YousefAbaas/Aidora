import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bottom_nav_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/my_requests_model.dart';
import '../models/request_model.dart';
import '../services/notification_service.dart';
import '../services/requests_api_service.dart';
import '../widgets/profile_avatar.dart';
import 'my_requests_screen.dart';
import 'notifications_screen.dart';
import 'qr_scanner_screen.dart';

class RequestsDashboardScreen extends StatefulWidget {
  final RequestsApiService? apiService;

  const RequestsDashboardScreen({super.key, this.apiService});

  static void refresh() => _RequestsDashboardScreenState.refreshFromOutside();

  @override
  State<RequestsDashboardScreen> createState() =>
      _RequestsDashboardScreenState();
}

class _RequestsDashboardScreenState extends State<RequestsDashboardScreen> {
  static _RequestsDashboardScreenState? _instance;
  static void refreshFromOutside() => _instance?._load();

  static const Color _green = Color(0xFF2C5F4F);
  static const Color _red = Color(0xFFE74C3C);
  static const Color _bg = Color(0xFFF5F3ED);

  late final RequestsApiService _svc;
  MyRequestsModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _instance = this;
    // التعديل الجوهري: استخدام widget.apiService أو effective للـ Mocking
    _svc = widget.apiService ?? RequestsApiService.effective;
    _load();
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    final r = await _svc.fetchMyRequests();
    if (!mounted) return;
    setState(() {
      _data = r.isSuccess ? r.data : null;
      _error = r.isSuccess ? null : r.errorMessage;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : _error != null
                ? _errorView()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: _green,
                    child: _body(),
                  ),
      ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
      );

  Widget _body() {
    final d = _data;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _header(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My request',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E28))),
            GestureDetector(
              onTap: () => Get.to(() => const MyRequestsScreen(),
                  transition: Transition.cupertino),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFF2C5F4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('View All',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C5F4F))),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Color(0xFF2C5F4F)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Obx(() => Text('Welcome back, ${ProfileController.to.displayName}',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
        const SizedBox(height: 20),
        Row(children: [
          _StatBox(
              value: '${d?.total ?? 0}',
              label: 'Total',
              valueColor: const Color(0xFF2C3E3C)),
          const SizedBox(width: 12),
          _StatBox(
              value: '${d?.approved ?? 0}',
              label: 'Approved',
              valueColor: const Color(0xFF27AE60),
              bgColor: const Color(0xFFF0FBF4)),
          const SizedBox(width: 12),
          _StatBox(
              value: '${d?.rejected ?? 0}',
              label: 'Rejected',
              valueColor: _red,
              bgColor: const Color(0xFFFFF5F5)),
        ]),
        const SizedBox(height: 24),
        if ((d?.approvedRequests ?? []).isNotEmpty) ...[
          _sectionHeader(
            color: const Color(0xFF27AE60),
            title: 'Approved Requests',
            showViewAll: true,
          ),
          const SizedBox(height: 12),
          ...d!.approvedRequests.map((r) => _ApprovedCard(
                req: r,
                onScanQR: () => _goToQR(r),
              )),
          const SizedBox(height: 20),
        ],
        if ((d?.rejectedRequests ?? []).isNotEmpty) ...[
          _sectionHeader(
            color: _red,
            title: 'Rejected Requests',
            showViewAll: false,
          ),
          const SizedBox(height: 12),
          ...(_data?.rejectedRequests ?? []).map((r) => _RejectedCard(req: r)),
          const SizedBox(height: 20),
        ],
        if (d == null ||
            (d.approvedRequests.isEmpty && d.rejectedRequests.isEmpty))
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Icon(Icons.inbox_rounded, size: 52, color: Colors.grey[300]),
              const SizedBox(height: 12),
              const Text('No requests yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A5A5A))),
              const SizedBox(height: 4),
              Text('Tap "New Request" below to apply for aid.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400])),
            ]),
          ),
        _newRequestCard(),
      ],
    );
  }

  Widget _header() => Row(children: [
        const ProfileAvatar(size: 46, borderColor: _green),
        const SizedBox(width: 12),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back,',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Obx(() => Text(ProfileController.to.displayName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E3C)))),
            ]),
        const Spacer(),
        Obx(() {
          final count = NotificationService.to.unreadCount.value;
          return Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06), blurRadius: 8)
                  ]),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF2C3E3C), size: 20),
                onPressed: () {
                  NotificationService.to.fetchFromApi();
                  Get.to(() => const NotificationsScreen(),
                      transition: Transition.cupertino);
                },
              ),
            ),
            if (count > 0)
              Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE74C3C), shape: BoxShape.circle),
                    child: Center(
                        child: Text(count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold))),
                  )),
          ]);
        }),
      ]);

  Widget _sectionHeader({
    required Color color,
    required String title,
    required bool showViewAll,
  }) =>
      Row(children: [
        Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const Spacer(),
        GestureDetector(
          onTap: () => Get.to(() => const MyRequestsScreen(),
              transition: Transition.cupertino),
          child: const Text('View All',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C5F4F),
                  fontWeight: FontWeight.w600)),
        ),
      ]);

  Future<void> _goToQR(ApprovedRequest req) async {
    final rm = RequestModel(
      id: req.id.toString(),
      ref: req.ref,
      status: 'approved',
      serviceName: req.serviceName,
      orgName: '',
      sector: req.sector,
      approvedAt: req.approvedAt,
    );
    final result = await Get.to(() => QRScannerScreen(request: rm),
        transition: Transition.cupertino);
    if (result == true) _load();
  }

  Widget _newRequestCard() => GestureDetector(
        onTap: () {
          try {
            Get.find<BottomNavController>().changeTab(0);
          } catch (_) {
            Get.back();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: _green.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: _green, size: 26),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('New Request',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E28))),
              const SizedBox(height: 2),
              Text('Apply for aid',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400], size: 16),
          ]),
        ),
      );
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color valueColor;
  final Color bgColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
    this.bgColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: valueColor)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
        ),
      );
}

class _ApprovedCard extends StatelessWidget {
  final ApprovedRequest req;
  final VoidCallback onScanQR;
  const _ApprovedCard({required this.req, required this.onScanQR});

  static const Color _green = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _badge(Icons.check_circle_outline_rounded, 'Approved', _green,
                    const Color(0xFFF0FBF4)),
                const SizedBox(width: 8),
                Text(req.ref,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.check_rounded, color: _green, size: 20),
              ]),
              const SizedBox(height: 10),
              Text(req.serviceName,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E3C))),
              const SizedBox(height: 6),
              Row(children: [
                if (req.sector.isNotEmpty) ...[
                  const Icon(Icons.home_outlined,
                      size: 14, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text(req.sector,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E))),
                  const SizedBox(width: 12),
                ],
                if (req.approvedAt.isNotEmpty) ...[
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text(req.approvedAt,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E))),
                ],
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
            decoration: const BoxDecoration(
                color: Color(0xFFF7FFF9),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(14))),
            child: Row(children: [
              const Text('Ready for Pickup',
                  style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const Spacer(),
              OutlinedButton(
                onPressed: onScanQR,
                style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Scan QR Code',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ]),
      );
}

class _RejectedCard extends StatelessWidget {
  final RejectedRequest req;
  const _RejectedCard({required this.req});

  static const Color _red = Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _badge(Icons.cancel_outlined, 'Rejected', _red,
                const Color(0xFFFFF5F5)),
            const SizedBox(width: 8),
            Text(req.ref,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.close_rounded, color: _red, size: 20),
          ]),
          const SizedBox(height: 10),
          Text(req.serviceName,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E3C))),
          if (req.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 8),
            Text('Reason: ${req.rejectionReason}',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF5A5A5A), height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.to(() => const MyRequestsScreen(),
                transition: Transition.cupertino),
            child: const Text('Review Reason',
                style: TextStyle(
                    color: _red, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ]),
      );
}

Widget _badge(IconData icon, String label, Color color, Color bg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
