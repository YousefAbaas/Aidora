import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/organization.dart';
import '../utils/organizations_data.dart';
import '../widgets/profile_avatar.dart';

class RefugeeHomeScreen extends StatelessWidget {
  const RefugeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5F3ED),
              child: Row(
                children: [
                  // Profile Image
                  const ProfileAvatar(size: 50, borderColor: Colors.green),
                  const SizedBox(width: 12),
                  // Welcome text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'Yousef Abbas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification icon
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.black, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 28),
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Supporting Organization for the Application',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Describe your needs (e.g. I need food)',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Organizations list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: organizationsData.length,
                      itemBuilder: (context, index) {
                        final org = organizationsData[index];
                        return _buildOrganizationCard(org);
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildOrganizationCard(Organization org) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'img/org_${org.id}.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.business, color: Colors.grey[400]);
                },
              ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0095DA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  org.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    // Request Help button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Request help
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text(
                          'Request Help',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Details button
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/organization-details', arguments: org);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0095DA),
                      ),
                      child: Row(
                        children:  [
                          Text('details'.tr,),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2C5F2D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed('/my-requests');
          } else if (index == 2) {
            Get.toNamed('/refugee-profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
