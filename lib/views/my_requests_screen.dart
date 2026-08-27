import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/request_model.dart';
import '../services/requests_api_service.dart';
import 'qr_scanner_screen.dart';
import 'request_details_screen.dart';

/// MyRequestsScreen â€” "View All" from the dashboard
/// GET /api/requests/list/              â†’ all
/// GET /api/requests/list/?status=xxx  â†’ filtered
///
/// Tabs: All | Approved | Pending | Rejected | Completed
class MyRequestsScreen extends StatefulWidget {
  final RequestsApiService? apiService;

  const MyRequestsScreen({super.key, this.apiService});

  /// Call after a new request is submitted to force a data refresh.
  static void refresh() => _MyRequestsScreenState.refreshFromOutside();

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg = Color(0xFFF5F3ED);

  static _MyRequestsScreenState? _instance;
  static void refreshFromOutside() => _instance?._refreshAll();

  static const _tabs = [
    {'label': 'All', 'status': 'all'},
    {'label': 'Approved', 'status': 'approved'},
    {'label': 'Pending', 'status': 'pending'},
    {'label': 'Rejected', 'status': 'rejected'},
    {'label': 'Completed', 'status': 'completed'},
  ];

  late TabController _tab;
  late final RequestsApiService _svc;

  final Map<String, List<RequestModel>> _items = {};
  final Map<String, bool> _loaded = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};
  Map<String, int> _counts = {};

  void _refreshAll() {
    if (!mounted) return;
    _loaded.clear();
    final status = _tabs[_tab.index]['status']!;
    _loadTab(status);
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
    // ØªÙ… Ø§Ù„ØªØ¹Ø¯ÙŠÙ„ Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù… effective Ù„Ø¯Ø¹Ù… Fake/Mock Ø£Ø«Ù†Ø§Ø¡ Ø§Ø®ØªØ¨Ø§Ø±Ø§Øª Ø§Ù„Ù€ Widgets
    _svc = widget.apiService ?? RequestsApiService.effective;
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(_onTabChanged);
    _loadTab('all');
  }

  @override
  void dispose() {
    _instance = null;
    _tab.removeListener(_onTabChanged);
    _tab.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tab.indexIsChanging) return;
    final status = _tabs[_tab.index]['status']!;
    if (!(_loaded[status] ?? false)) _loadTab(status);
  }

  Future<void> _loadTab(String status) async {
    setState(() {
      _loading[status] = true;
      _errors[status] = null;
    });

    final r =
        await _svc.fetchRequestList(status: status == 'all' ? null : status);
    if (!mounted) return;

    if (r.isSuccess) {
      setState(() {
        _items[status] = r.items;
        _counts = {..._counts, ...r.counts};
        _loading[status] = false;
        _loaded[status] = true;
      });
    } else {
      setState(() {
        _errors[status] = r.errorMessage;
        _loading[status] = false;
      });
    }
  }

  int _countFor(String status) {
    if (status == 'all') return _counts['All'] ?? 0;
    if (status == 'approved') return _counts['Approved'] ?? 0;
    if (status == 'completed') return _counts['Completed'] ?? 0;
    if (status == 'pending') return _counts['Pending'] ?? 0;
    if (status == 'rejected') return _counts['Rejected'] ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Color(0xFF2C3E3C), size: 20),
                onPressed: () => Get.back(),
              ),
              const Text('My Requests',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E28))),
            ]),
          ),

          const SizedBox(height: 12),

          // â”€â”€ Tab bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                  color: _green, borderRadius: BorderRadius.circular(20)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: _tabs.map((t) {
                final n = _countFor(t['status']!);
                return Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('${t['label']} ($n)'),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // â”€â”€ Tab views â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: TabBarView(
              controller: _tab,
              physics: const NeverScrollableScrollPhysics(),
              children: _tabs.map((t) {
                final status = t['status']!;
                return _TabPage(
                  status: status,
                  items: _items[status] ?? [],
                  loading: _loading[status] ?? false,
                  error: _errors[status],
                  onRetry: () => _loadTab(status),
                  onScanQR: _handleScanQR,
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _handleScanQR(RequestModel req) async {
    final result = await Get.to(() => QRScannerScreen(request: req),
        transition: Transition.cupertino);
    if (result == true) {
      final status = _tabs[_tab.index]['status']!;
      _loaded[status] = false;
      _loadTab(status);
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TabPage extends StatelessWidget {
  final String status;
  final List<RequestModel> items;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final Future<void> Function(RequestModel) onScanQR;

  const _TabPage({
    required this.status,
    required this.items,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onScanQR,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C5F4F)));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ]),
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 12),
          Text('No requests',
              style: TextStyle(fontSize: 15, color: Colors.grey[400])),
        ]),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, i) =>
          _RequestCard(request: items[i], onScanQR: onScanQR),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Request Card
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final Future<void> Function(RequestModel) onScanQR;
  const _RequestCard({required this.request, required this.onScanQR});

  Color get _accentColor {
    switch (request.status) {
      case 'approved':
        return const Color(0xFF27AE60);
      case 'completed':
        return const Color(0xFF2980B9);
      case 'pending':
        return const Color(0xFFE67E22);
      case 'rejected':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  Color get _badgeBg {
    switch (request.status) {
      case 'approved':
        return const Color(0xFFF0FBF4);
      case 'completed':
        return const Color(0xFFEBF5FB);
      case 'pending':
        return const Color(0xFFFFF3E8);
      case 'rejected':
        return const Color(0xFFFFF5F5);
      default:
        return Colors.grey[100]!;
    }
  }

  String get _label {
    switch (request.status) {
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return request.status;
    }
  }

  IconData get _icon {
    switch (request.status) {
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  bool get _isApproved => request.status == 'approved';
  bool get _isCompleted => request.status == 'completed';
  bool get _isPending => request.status == 'pending';
  bool get _isRejected => request.status == 'rejected';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status badge + REF
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _accentColor.withValues(alpha: 0.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_icon, color: _accentColor, size: 13),
                const SizedBox(width: 5),
                Text(_label,
                    style: TextStyle(
                        color: _accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 10),
            Text(request.ref,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600)),
          ]),

          const SizedBox(height: 10),

          // Service name
          Text(request.serviceName,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E28))),

          const SizedBox(height: 8),

          // Info row
          if (_isApproved) ...[
            if (request.sector != null && request.sector!.isNotEmpty)
              _infoRow(Icons.home_outlined, request.sector!),
            if (request.approvedAt != null)
              _infoRow(Icons.schedule_rounded, request.approvedAt!),
            const SizedBox(height: 10),
            Row(children: [
              const Text('Ready for pickup',
                  style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const Spacer(),
              OutlinedButton(
                onPressed: () => onScanQR(request),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27AE60),
                    side:
                        const BorderSide(color: Color(0xFF27AE60), width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Scan QR Code',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ],

          if (_isPending && request.createdAt != null)
            _infoRow(Icons.access_time_rounded, request.createdAt!),

          if (_isCompleted)
            _infoRow(
                Icons.check_circle_outline, request.receivedAt ?? 'Completed'),

          if (_isRejected &&
              request.rejectionReason != null &&
              request.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFCDD2))),
              child: Text(
                '"${request.rejectionReason}"',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE74C3C),
                    fontStyle: FontStyle.italic,
                    height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          if (_isCompleted) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Get.to(
                    () => RequestDetailsScreen(request: request),
                    transition: Transition.cupertino),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2980B9),
                    side:
                        const BorderSide(color: Color(0xFF2980B9), width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Details',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(children: [
          Icon(icon, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 5),
          Flexible(
              child: Text(text,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}
