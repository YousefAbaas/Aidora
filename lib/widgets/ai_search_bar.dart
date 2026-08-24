import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/settings_controller.dart';
import '../utils/app_theme.dart';

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// AiSearchBar
/// Natural language search field.  When the user submits text, it calls the
/// Anthropic API to map their query to a service_type string, then fires
/// [onServiceDetected] with the result so the parent screen can call the
/// Django filter endpoint.
///
/// Example queries:
///   "I need food"         â†’ "Food"
///   "Ø£Ø­ØªØ§Ø¬ Ù…Ø³Ø§Ø¹Ø¯Ø© Ø·Ø¨ÙŠØ©"   â†’ "Health"
///   "my children need school" â†’ "Education"
/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AiSearchBar extends StatefulWidget {
  final Future<void> Function(String serviceType) onServiceDetected;
  final VoidCallback onFilterTap;
  final bool isFiltered;

  const AiSearchBar({
    super.key,
    required this.onServiceDetected,
    required this.onFilterTap,
    this.isFiltered = false,
  });

  @override
  State<AiSearchBar> createState() => _AiSearchBarState();
}

class _AiSearchBarState extends State<AiSearchBar> {
  final _ctrl = TextEditingController();
  bool _aiLoading = false;

  static const _green = Color(0xFF2C5F4F);

  // â”€â”€ Known service types from Django â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _services = [
    'Education',
    'Emergency Response',
    'Food',
    'Health',
    'Legal Assistance',
    'Logistics Support',
    'Protection',
    'Shelter',
    'Vaccination',
    'Water and Sanitation',
    'Child Protection',
  ];

  // â”€â”€ Call Anthropic API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _aiLoading = true);

    try {
      final resp = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'claude-sonnet-4-20250514',
              'max_tokens': 50,
              'messages': [
                {
                  'role': 'user',
                  'content': 'A refugee app user typed: "$q"\n\n'
                      'Match their need to EXACTLY ONE of these service types:\n'
                      '${_services.join(", ")}\n\n'
                      'Reply with ONLY the exact service type string and nothing else. '
                      'If nothing matches, reply with the word: NONE',
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => _aiLoading = false);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = (body['content'] as List).first;
        final answer = (content['text'] as String).trim();

        if (answer == 'NONE' || !_services.contains(answer)) {
          Get.snackbar(
            'AI Search',
            'ai_no_match'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
          );
        } else {
          _ctrl.text = answer;
          await widget.onServiceDetected(answer);
        }
      } else {
        _fallback(q);
      }
    } catch (_) {
      if (mounted) setState(() => _aiLoading = false);
      _fallback(q);
    }
  }

  // â”€â”€ Local fallback keyword map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _fallback(String q) {
    final lower = q.toLowerCase();
    final kw = <String, List<String>>{
      'Food': ['food', 'eat', 'hunger', 'meal', 'Ø·Ø¹Ø§Ù…', 'Ø¬ÙˆØ¹', 'Ø£ÙƒÙ„'],
      'Health': [
        'health',
        'sick',
        'doctor',
        'medical',
        'Ù…Ø±Ø¶',
        'Ø·Ø¨ÙŠØ¨',
        'ØµØ­Ø©'
      ],
      'Education': [
        'school',
        'study',
        'education',
        'learn',
        'Ù…Ø¯Ø±Ø³Ø©',
        'ØªØ¹Ù„ÙŠÙ…',
        'Ø¯Ø±Ø§Ø³Ø©'
      ],
      'Water and Sanitation': [
        'water',
        'sanit',
        'clean',
        'Ù…Ø§Ø¡',
        'Ù…ÙŠØ§Ù‡',
        'Ù†Ø¸Ø§ÙØ©'
      ],
      'Protection': [
        'protect',
        'safe',
        'danger',
        'Ø­Ù…Ø§ÙŠØ©',
        'Ø£Ù…Ø§Ù†',
        'Ø®Ø·Ø±'
      ],
      'Shelter': ['shelter', 'home', 'house', 'Ù…Ø£ÙˆÙ‰', 'Ù…Ù†Ø²Ù„', 'Ø³ÙƒÙ†'],
      'Emergency Response': [
        'emergency',
        'urgent',
        'crisis',
        'Ø·ÙˆØ§Ø±Ø¦',
        'Ø£Ø²Ù…Ø©',
        'Ø¹Ø§Ø¬Ù„'
      ],
      'Legal Assistance': [
        'legal',
        'law',
        'document',
        'Ù‚Ø§Ù†ÙˆÙ†',
        'ÙˆØ«ÙŠÙ‚Ø©',
        'Ù…Ø­Ø§Ù…ÙŠ'
      ],
      'Child Protection': ['child', 'children', 'kid', 'Ø·ÙÙ„', 'Ø£Ø·ÙØ§Ù„'],
      'Vaccination': [
        'vaccine',
        'vaccination',
        'immunize',
        'ØªØ·Ø¹ÙŠÙ…',
        'Ù„Ù‚Ø§Ø­'
      ],
      'Logistics Support': [
        'transport',
        'deliver',
        'supply',
        'Ù†Ù‚Ù„',
        'ØªÙˆØµÙŠÙ„'
      ],
    };
    for (final entry in kw.entries) {
      if (entry.value.any((k) => lower.contains(k))) {
        widget.onServiceDetected(entry.key);
        return;
      }
    }
    Get.snackbar('AI Search', 'ai_no_match'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: context.shadowColor.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            // AI spark icon
            Icon(Icons.auto_awesome_rounded,
                size: 18, color: _aiLoading ? _green : Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: TextStyle(fontSize: 14, color: context.textColor),
                textDirection: SettingsController.to.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr,
                  hintStyle: TextStyle(color: context.textSub, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: _search,
              ),
            ),
            if (_aiLoading)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: _green),
                ),
              )
            else if (_ctrl.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.send_rounded, size: 18, color: _green),
                onPressed: () => _search(_ctrl.text),
                padding: const EdgeInsets.only(right: 8),
                constraints: const BoxConstraints(),
              ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      // Filter button
      GestureDetector(
        onTap: widget.onFilterTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isFiltered ? Colors.orange : _green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: (widget.isFiltered ? Colors.orange : _green)
                      .withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Icon(widget.isFiltered ? Icons.filter_alt : Icons.tune_rounded,
              color: Colors.white, size: 21),
        ),
      ),
    ]);
  }
}
