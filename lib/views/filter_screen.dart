import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selected;

  static const List<Map<String, dynamic>> _filters = [
    {
      'id': 'Child Protection',
      'label': 'Child Protection',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF1565C0)
    },
    {
      'id': 'Education',
      'label': 'Education',
      'icon': Icons.school_rounded,
      'color': Color(0xFFF57C00)
    },
    {
      'id': 'Water and Sanitation',
      'label': 'Water & Sanitation',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF0277BD)
    },
    {
      'id': 'Health',
      'label': 'Healthcare & Medical',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFFD32F2F)
    },
    {
      'id': 'Food',
      'label': 'Food Assistance',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFE65100)
    },
    {
      'id': 'Shelter',
      'label': 'Shelter & Crisis',
      'icon': Icons.home_rounded,
      'color': Color(0xFF4527A0)
    },
    {
      'id': 'Emergency Response',
      'label': 'Emergency Response',
      'icon': Icons.emergency_rounded,
      'color': Color(0xFFC62828)
    },
    {
      'id': 'Logistics Support',
      'label': 'Logistics Support',
      'icon': Icons.local_shipping_rounded,
      'color': Color(0xFF00695C)
    },
    {
      'id': 'Vaccination',
      'label': 'Vaccination',
      'icon': Icons.vaccines_rounded,
      'color': Color(0xFF2E7D32)
    },
    {
      'id': 'Legal Assistance',
      'label': 'Legal Assistance',
      'icon': Icons.gavel_rounded,
      'color': Color(0xFF37474F)
    },
    {
      'id': 'Protection',
      'label': 'Protection',
      'icon': Icons.security_rounded,
      'color': Color(0xFF1A237E)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // â”€â”€ FIX: wrap in SafeArea + use resizeToAvoidBottomInset
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Filter by Service',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.text),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      // â”€â”€ FIX: Column â†’ make list Expanded so it never overflows
      body: SafeArea(
        child: Column(
          children: [
            // List takes all available space
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filters.length,
                itemBuilder: (_, i) => _buildItem(_filters[i]),
              ),
            ),
            // Bottom buttons â€” always at the bottom, never overflow
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3))
                ],
              ),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _selected = null),
                    icon: const Icon(Icons.clear, size: 18),
                    label: Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selected == null) {
                        Get.snackbar(
                            'No Filter', 'Please select a service category',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor:
                                Colors.orange.withValues(alpha: 0.15),
                            colorText: Colors.orange,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12);
                        return;
                      }
                      Get.back(result: [_selected]);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Show Results',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final isSelected = _selected == item['id'];
    final color = item['color'] as Color;
    return GestureDetector(
      onTap: () => setState(() => _selected = item['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.grey[200]!,
              width: isSelected ? 1.8 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(item['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(item['label'],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : AppColors.text)),
          ),
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14),
            ),
        ]),
      ),
    );
  }
}
