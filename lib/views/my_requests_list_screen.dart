import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../controllers/requests_controller.dart';
import '../models/request_model.dart';
import 'request_details_screen.dart';

class MyRequestsListScreen extends StatefulWidget {
  const MyRequestsListScreen({super.key});

  @override
  State<MyRequestsListScreen> createState() =>
      _MyRequestsListScreenState();
}

class _MyRequestsListScreenState extends State<MyRequestsListScreen> {
  final RequestsController ctrl = Get.find<RequestsController>();
  final TextEditingController searchCtrl = TextEditingController();
  String selectedFilter = 'All';

  List<RequestModel> get _filtered {
    List<RequestModel> list;
    switch (selectedFilter) {
      case 'Approved':
        list = ctrl.getByStatus('approved');
        break;
      case 'Pending':
        list = ctrl.getByStatus('pending');
        break;
      case 'Rejected':
        list = ctrl.getByStatus('rejected');
        break;
      case 'Completed':
        list = ctrl.getByStatus('completed');
        break;
      default:
        list = ctrl.allRequests.toList();
    }
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((r) =>
              (r.title ?? r.serviceName).toLowerCase().contains(q) ||
              r.refNumber.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Requests',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by title or reference...',
                hintStyle:
                    TextStyle(color: AppColors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
          Obx(() {
            return SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip('All', ctrl.totalCount),
                  const SizedBox(width: 8),
                  _chip('Approved', ctrl.approvedCount),
                  const SizedBox(width: 8),
                  _chip('Pending', ctrl.pendingCount),
                  const SizedBox(width: 8),
                  _chip('Rejected', ctrl.rejectedCount),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: Obx(() {
              final items = _filtered;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: AppColors.grey),
                      const SizedBox(height: 16),
                      Text('No requests found',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (_, i) => _card(items[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int count) {
    final sel = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: sel ? AppColors.primary : AppColors.greyLight),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                sel ? FontWeight.w700 : FontWeight.normal,
            color: sel ? AppColors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _card(RequestModel r) {
    Color color;
    IconData icon;
    String label;
    switch (r.status) {
      case 'approved':
        color = const Color(0xFF2980B9);
        icon = Icons.thumb_up_rounded;
        label = 'Approved';
        break;
      case 'complete':
        color = const Color(0xFF27AE60);
        icon = Icons.check_circle_rounded;
        label = 'Completed';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
        label = 'Pending';
    }

    return GestureDetector(
      onTap: (r.status == 'complete' || r.status == 'approved')
          ? () => Get.to(
                () => RequestDetailsScreen(request: r),
                transition: Transition.cupertino,
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const Spacer(),
                  Text('REF: ${r.refNumber}',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.grey)),
                ],
              ),
              const SizedBox(height: 10),
              Text(r.title ?? r.serviceName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text)),
              if (r.submittedTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 13, color: AppColors.grey),
                    const SizedBox(width: 5),
                    Text('Submitted ${r.submittedTime}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
