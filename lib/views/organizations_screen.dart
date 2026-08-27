import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../utils/organizations_data.dart';
import '../models/organization.dart';
import '../widgets/org_initial_avatar.dart';
import 'organization_details_screen.dart';
import 'filter_screen.dart';
import 'submit_new_request_screen.dart';

class OrganizationsScreen extends StatelessWidget {
  final String? selectedCategory;

  const OrganizationsScreen({super.key, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final filteredOrgs = selectedCategory == null
        ? organizationsData
        : organizationsData
            .where((org) => org.categories.contains(selectedCategory))
            .toList();

    // Ø¥Ø°Ø§ ÙƒØ§Ù† Ù‡Ù†Ø§Ùƒ ÙÙ„ØªØ±Ø©ØŒ Ù†Ø£Ø®Ø° Ø£ÙˆÙ„ Ù…Ù†Ø¸Ù…Ø© ÙÙ‚Ø·
    final orgsToShow = selectedCategory != null && filteredOrgs.isNotEmpty
        ? [filteredOrgs.first]
        : filteredOrgs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
        title: Text(
          selectedCategory ?? 'Organizations',
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.text),
            onPressed: () async {
              final result = await Get.to(() => const FilterScreen());
              if (result != null && result is List && result.isNotEmpty) {
                Get.off(() => OrganizationsScreen(selectedCategory: result[0]));
              }
            },
          ),
        ],
      ),
      body: orgsToShow.isEmpty
          ? const Center(
              child: Text('No organizations found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orgsToShow.length,
              itemBuilder: (context, index) {
                final org = orgsToShow[index];
                return _buildOrganizationCard(org);
              },
            ),
    );
  }

  Widget _buildOrganizationCard(Organization org) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'img/org_${org.id}.png',
                  fit: BoxFit.contain,
                  width: 44,
                  height: 44,
                  errorBuilder: (_, __, ___) =>
                      OrgInitialAvatar(name: org.name, size: 44),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      org.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => SubmitNewRequestScreen(
                          orgName: org.name,
                        ));
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    'request_help'.tr,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.to(() => const OrganizationDetailsScreen(),
                        arguments: org);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    'details'.tr,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: BorderSide(color: AppColors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
