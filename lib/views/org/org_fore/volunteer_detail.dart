import 'package:aidora/controllers/form_controller.dart';
import 'package:aidora/views/org/org_fore/reject.dart';
import 'package:aidora/views/org/org_fore/success.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VolunteerDetailScreen extends StatelessWidget {
  VolunteerDetailScreen({super.key, required this.index});

  final int index;
  final FormController controller = Get.find();
  // Ø­Ù‚Ù† Ø§Ù„Ù…ØªØ­ÙƒÙ…
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f2eb),
      appBar: AppBar(
        title: const Text('Volunteer Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Obx(() {
        final v = controller.listallpagefore[index];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircleAvatar(child: Icon(Icons.add)),
              ),
              // Ø§Ø³Ù… Ø§Ù„Ù…ØªØ·ÙˆØ¹ ÙˆÙˆÙ‚Øª Ø§Ù„ØªÙ‚Ø¯ÙŠÙ…
              Column(
                children: [
                  Text(
                    v.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    v.appliedTime,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ø´Ø®ØµÙŠØ©
              _buildSectionCard(
                title: 'PERSONAL INFORMATION',
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.markunread,
                            color: Color(0xffec5b13),
                          ),
                        ),
                        SizedBox(width: 10),
                        _buildInfoRow('Email', v.email),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.phone, color: Color(0xffec5b13)),
                        ),
                        SizedBox(width: 10),
                        _buildInfoRow('Phone Number', v.phone),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Color(0xffec5b13)),
                            SizedBox(width: 10),
                            _buildInfoRow('Age', '${v.age} Years'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Color(0xffec5b13),
                            ),
                            SizedBox(width: 10),
                            _buildInfoRow('Location', v.location),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ID : #${v.idNumber}"),
                        Text("Nationality : ${v.nationality}"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„ØªÙˆÙØ±
              _buildSectionCard(
                title: 'AVAILABILITY',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.access_time, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoRow(v.days, v.availabilityDays.join(' , ')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Start date : ${v.startDate}"),
                    const SizedBox(height: 8),
                    Text("Expected duration : ${v.duration}"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ù…Ù‡Ø§Ø±Ø§Øª ÙˆØ§Ù„Ø®Ø¨Ø±Ø©
              _buildSectionCard(
                title: 'SKILLS & EXPERIENCE',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.translate),
                            SizedBox(width: 5),
                            _buildInfoRow(
                              'LANGUAGES : ',
                              v.languages.join(' & '),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.school),
                            SizedBox(width: 5),
                            _buildInfoRow('EDUCATION : ', v.education),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Experience : ', v.experience),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø© Ø§Ù„Ù…Ù…ÙƒÙ† ØªÙ‚Ø¯ÙŠÙ…Ù‡Ø§
              _buildSectionCard(
                title: 'THE HELP HE CAN PROVIDE',
                child: Column(
                  children: [
                    ...List.generate(v.helpProvided.length, (i) {
                      return Row(
                        children: [
                          Icon(
                            controller.iconsMap[v.logo[i]]?.icon,
                            color: controller.iconsMap[v.logo[i]]?.color,
                          ),
                          SizedBox(width: 15),
                          Text(v.helpProvided[i]),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ø¨Ø·Ø§Ù‚Ø© Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø¥Ø¶Ø§ÙÙŠØ©
              _buildSectionCard(
                title: 'MORE INFORMATION',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency Contact : ${v.emergencyContact}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Why did he volunteer : ${v.reason}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ø²Ø±Ø§ Ø§Ù„Ø±ÙØ¶ ÙˆØ§Ù„Ù‚Ø¨ÙˆÙ„
              if (v.state == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.to(() => RejectApplicationPage(index: index));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'X Reject',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.to(() => SuccessAcceptancePage(index: index));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  // ÙˆÙŠØ¯Ø¬Øª Ù…Ø³Ø§Ø¹Ø¯ Ù„Ø¨Ù†Ø§Ø¡ ØµÙ Ù…Ø¹Ù„ÙˆÙ…Ø§Øª (Ø¹Ù†ÙˆØ§Ù† - Ù‚ÙŠÙ…Ø©)
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ÙˆÙŠØ¯Ø¬Øª Ù…Ø³Ø§Ø¹Ø¯ Ù„Ø¨Ù†Ø§Ø¡ Ø¨Ø·Ø§Ù‚Ø© Ù‚Ø³Ù…
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
