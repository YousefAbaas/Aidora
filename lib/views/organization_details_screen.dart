import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/organization.dart';
import 'submit_new_request_screen.dart';

class OrganizationDetailsScreen extends StatelessWidget {
  const OrganizationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Organization organization = Get.arguments as Organization;

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
          organization.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            organization.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.business, size: 50),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  organization.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(organization.id),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // About Mission
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Mission',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _getAboutMission(organization.id),
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Target Groups
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Groups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getTargetGroups(organization.id)
                      .map((group) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              group,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Services Provided
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Services Provided',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${_getServices(organization.id).length} Key Areas',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._getServices(organization.id).map((service) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: service['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(service['icon'],
                              color: service['color'], size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Service Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['title'],
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service['description'],
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        // + Button â†’ navigate to submit request
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => SubmitNewRequestScreen(
                                orgName: organization.name,
                              ),
                              transition: Transition.cupertino,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C5F4F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Our Impact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Impact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'img/impact_${organization.id}_1.png',
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'img/impact_${organization.id}_2.png',
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Contact Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _contactRow(
                  icon: Icons.language,
                  iconBg: Colors.blue[50]!,
                  iconColor: Colors.blue,
                  label: 'Official Website',
                ),
                const SizedBox(height: 12),
                _contactRow(
                  icon: Icons.phone,
                  iconBg: Colors.green[50]!,
                  iconColor: Colors.green,
                  label: 'Contact Us',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(String id) {
    const map = {
      'unicef': 'Global Aid Organization',
      'unhcr': 'The UN Refugee Agency',
      'wfp': 'Global Humanitarian Organization',
      'who': 'Global Health Agency',
      'red_crescent': 'Humanitarian Organization',
      'intersos': 'Emergency Response Organization',
    };
    return map[id] ?? 'Humanitarian Organization';
  }

  String _getAboutMission(String id) {
    const map = {
      'unicef':
          'UNICEF works in over 190 countries and territories to save children\'s lives, to defend their rights, and to help them fulfill their potential, from early childhood through adolescence. We work tirelessly to reach the world\'s most vulnerable and marginalized children.',
      'unhcr':
          'UNHCR works to protect refugees and displaced individuals by providing legal support, temporary shelter, essential services, and assistance in asylum and resettlement processes. We strive to save lives and build better futures for millions forced from home.',
      'wfp':
          'World Food Programme provides essential food assistance and works to prevent malnutrition, supporting vulnerable groups to ensure fair and reliable access to nutrition. We strive to build a world with zero hunger.',
      'who':
          'World Health Organization provides urgent health guidance, emergency medical support, preventive programs, and field assistance to healthcare systems during crises and disease outbreaks.',
      'red_crescent':
          'Red Crescent provides urgent medical and humanitarian assistance, including emergency healthcare, food distribution, psychological support, and rapid disaster response to affected communities.',
      'intersos':
          'INTERSOS provides emergency humanitarian assistance to victims of natural disasters and armed conflicts in the world\'s most vulnerable regions.',
    };
    return map[id] ?? 'Dedicated to providing humanitarian assistance.';
  }

  List<String> _getTargetGroups(String id) {
    const map = {
      'unicef': [
        'Children',
        'Refugees',
        'Mothers',
        'Conflict Zones',
        'Education'
      ],
      'unhcr': [
        'Persecuted Individuals',
        'Displaced Families',
        'Refugees',
        'IDPs',
        'Asylum Seekers'
      ],
      'wfp': [
        'Households in need',
        'Children at risk',
        'Low-income communities',
        'Refugees',
        'Conflict zones'
      ],
      'who': [
        'Health Emergencies',
        'Refugees',
        'Outbreak Regions',
        'Vulnerable Individuals',
        'Healthcare Workers'
      ],
      'red_crescent': [
        'Children',
        'Refugees',
        'Mothers',
        'Conflict Zones',
        'Displaced Families'
      ],
      'intersos': [
        'Conflict Zones',
        'Displaced Persons',
        'Emergency Victims',
        'Vulnerable Communities'
      ],
    };
    return map[id] ?? ['General Population'];
  }

  List<Map<String, dynamic>> _getServices(String id) {
    switch (id) {
      case 'unicef':
        return [
          {
            'icon': Icons.shield,
            'color': Colors.blue,
            'title': 'Child Protection',
            'description':
                'Safe environment and legal support for children in danger zones.'
          },
          {
            'icon': Icons.school,
            'color': Colors.orange,
            'title': 'Education',
            'description':
                'Supporting schools, training teachers, and providing educational supplies.'
          },
          {
            'icon': Icons.water_drop,
            'color': Colors.cyan,
            'title': 'Water and Sanitation',
            'description':
                'Ensuring access to clean, drinkable water for communities.'
          },
        ];
      case 'unhcr':
        return [
          {
            'icon': Icons.shield,
            'color': Colors.blue,
            'title': 'Refugee & IDP Protection',
            'description':
                'Ensuring safety, registration, and identity documentation.'
          },
          {
            'icon': Icons.home,
            'color': Colors.orange,
            'title': 'Temporary Shelter',
            'description':
                'Essential housing support and temporary accommodation.'
          },
          {
            'icon': Icons.gavel,
            'color': Colors.indigo,
            'title': 'Legal Assistance',
            'description':
                'Support for asylum services, rights advocacy, and resettlement.'
          },
          {
            'icon': Icons.emergency,
            'color': Colors.red,
            'title': 'Emergency Relief',
            'description':
                'Critical humanitarian aid, food, water, and medical supplies.'
          },
        ];
      case 'wfp':
        return [
          {
            'icon': Icons.restaurant,
            'color': Colors.orange,
            'title': 'Food Assistance',
            'description':
                'Providing immediate food relief to populations in crisis.'
          },
          {
            'icon': Icons.health_and_safety,
            'color': Colors.green,
            'title': 'Malnutrition Prevention',
            'description':
                'Specialized programs to prevent stunting and deficiencies.'
          },
          {
            'icon': Icons.local_shipping,
            'color': Colors.blue,
            'title': 'Logistics Support',
            'description':
                'Managing supply chains for efficient food distribution globally.'
          },
          {
            'icon': Icons.pregnant_woman,
            'color': Colors.pink,
            'title': 'Maternal Nutrition',
            'description': 'Nutrition programs for children and pregnant women.'
          },
          {
            'icon': Icons.security,
            'color': Colors.purple,
            'title': 'Food Security & Development',
            'description':
                'Building long-term resilience and community development.'
          },
        ];
      case 'who':
        return [
          {
            'icon': Icons.emergency,
            'color': Colors.red,
            'title': 'Emergency Response',
            'description': 'Rapid emergency health response during crises.'
          },
          {
            'icon': Icons.coronavirus,
            'color': Colors.orange,
            'title': 'Disease Control',
            'description': 'Monitoring and controlling disease outbreaks.'
          },
          {
            'icon': Icons.medical_services,
            'color': Colors.pink,
            'title': 'Healthcare Systems',
            'description': 'Strengthening local healthcare infrastructure.'
          },
          {
            'icon': Icons.vaccines,
            'color': Colors.green,
            'title': 'Vaccination',
            'description':
                'Leading preventive healthcare and vaccination programs.'
          },
          {
            'icon': Icons.psychology,
            'color': Colors.purple,
            'title': 'Mental Health',
            'description': 'Psychosocial care and mental health support.'
          },
        ];
      case 'red_crescent':
        return [
          {
            'icon': Icons.medical_services,
            'color': Colors.red,
            'title': 'Medical Assistance',
            'description':
                'Emergency healthcare, ambulance services, and medical aid.'
          },
          {
            'icon': Icons.restaurant,
            'color': Colors.orange,
            'title': 'Food Distribution',
            'description':
                'Food aid parcels and essential supplies for displaced families.'
          },
          {
            'icon': Icons.psychology,
            'color': Colors.blue,
            'title': 'Psychological Support',
            'description':
                'Mental health services and social support for trauma recovery.'
          },
          {
            'icon': Icons.emergency,
            'color': Colors.green,
            'title': 'Disaster Response',
            'description': 'Rapid disaster management and emergency response.'
          },
          {
            'icon': Icons.favorite,
            'color': Colors.pink,
            'title': 'Health Services',
            'description':
                'Blood donation drives, transfusion services, and first-aid.'
          },
        ];
      case 'intersos':
        return [
          {
            'icon': Icons.shield_rounded,
            'color': Colors.blue,
            'title': 'Protection Services',
            'description':
                'Protecting vulnerable populations in emergency contexts.',
            'filterKey': 'protection'
          },
          {
            'icon': Icons.medical_services_rounded,
            'color': Colors.red,
            'title': 'Health Assistance',
            'description':
                'Emergency medical support in conflict-affected areas.',
            'filterKey': 'health'
          },
          {
            'icon': Icons.home_rounded,
            'color': Colors.orange,
            'title': 'Shelter Support',
            'description':
                'Temporary shelter and non-food items for displaced persons.',
            'filterKey': 'shelter'
          },
          {
            'icon': Icons.emergency_rounded,
            'color': Colors.red,
            'title': 'Emergency Relief',
            'description':
                'Rapid emergency response and critical humanitarian assistance.',
            'filterKey': 'emergency'
          },
          {
            'icon': Icons.gavel_rounded,
            'color': Colors.indigo,
            'title': 'Legal Aid',
            'description':
                'Legal assistance for displaced persons and asylum seekers.',
            'filterKey': 'legal'
          },
          {
            'icon': Icons.restaurant_rounded,
            'color': Colors.orange,
            'title': 'Emergency Food Assistance',
            'description':
                'Food distribution for families in acute crisis situations.',
            'filterKey': 'food'
          },
        ];
      default:
        return [];
    }
  }
}


