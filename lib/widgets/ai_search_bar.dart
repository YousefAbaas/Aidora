import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/settings_controller.dart';
import '../utils/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AiSearchBar
/// Natural language search field.  When the user submits text, it calls the
/// Anthropic API to map their query to a service_type string, then fires
/// [onServiceDetected] with the result so the parent screen can call the
/// Django filter endpoint.
///
/// Example queries:
///   "I need food"         → "Food"
///   "أحتاج مساعدة طبية"   → "Health"
///   "my children need school" → "Education"
/// ─────────────────────────────────────────────────────────────────────────────
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
  final _ctrl       = TextEditingController();
  bool  _aiLoading  = false;

  static const _green = Color(0xFF2C5F4F);

  // ── Known service types from Django ───────────────────────────────────────
  static const _services = [
    'Education', 'Emergency Response', 'Food', 'Health',
    'Legal Assistance', 'Logistics Support', 'Protection',
    'Shelter', 'Vaccination', 'Water and Sanitation',
    'Child Protection',
  ];

  // ── Call Anthropic API ─────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _aiLoading = true);

    try {
      final resp = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 50,
          'messages': [
            {
              'role': 'user',
              'content':
                  'A refugee app user typed: "$q"\n\n'
                  'Match their need to EXACTLY ONE of these service types:\n'
                  '${_services.join(", ")}\n\n'
                  'Reply with ONLY the exact service type string and nothing else. '
                  'If nothing matches, reply with the word: NONE',
            }
          ],
        }),
      ).timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => _aiLoading = false);

      if (resp.statusCode == 200) {
        final body    = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = (body['content'] as List).first;
        final answer  = (content['text'] as String).trim();

        if (answer == 'NONE' || !_services.contains(answer)) {
          Get.snackbar(
            'AI Search', 'ai_no_match'.tr,
            snackPosition:   SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.9),
            colorText:       Colors.white,
            margin:          const EdgeInsets.all(12),
            borderRadius:    12,
            duration:        const Duration(seconds: 3),
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

  // ── Local fallback keyword map ─────────────────────────────────────────────
  void _fallback(String q) {
    final lower = q.toLowerCase();
    final kw = <String, List<String>>{
      'Food':               ['food','eat','hunger','meal','طعام','جوع','أكل'],
      'Health':             ['health','sick','doctor','medical','مرض','طبيب','صحة'],
      'Education':          ['school','study','education','learn','مدرسة','تعليم','دراسة'],
      'Water and Sanitation':['water','sanit','clean','ماء','مياه','نظافة'],
      'Protection':         ['protect','safe','danger','حماية','أمان','خطر'],
      'Shelter':            ['shelter','home','house','مأوى','منزل','سكن'],
      'Emergency Response': ['emergency','urgent','crisis','طوارئ','أزمة','عاجل'],
      'Legal Assistance':   ['legal','law','document','قانون','وثيقة','محامي'],
      'Child Protection':   ['child','children','kid','طفل','أطفال'],
      'Vaccination':        ['vaccine','vaccination','immunize','تطعيم','لقاح'],
      'Logistics Support':  ['transport','deliver','supply','نقل','توصيل'],
    };
    for (final entry in kw.entries) {
      if (entry.value.any((k) => lower.contains(k))) {
        widget.onServiceDetected(entry.key);
        return;
      }
    }
    Get.snackbar('AI Search', 'ai_no_match'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12), borderRadius: 12);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Row(children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(
                color: context.shadowColor.withOpacity(0.06),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            // AI spark icon
            Icon(Icons.auto_awesome_rounded,
                size: 18,
                color: _aiLoading ? _green : Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: TextStyle(fontSize: 14, color: context.textColor),
                textDirection: SettingsController.to.isArabic
                    ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr,
                  hintStyle: TextStyle(
                      color: context.textSub, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: _search,
              ),
            ),
            if (_aiLoading)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _green),
                ),
              )
            else if (_ctrl.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.send_rounded, size: 18,
                    color: _green),
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
            boxShadow: [BoxShadow(
                color: (widget.isFiltered ? Colors.orange : _green)
                    .withOpacity(0.35),
                blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Icon(
            widget.isFiltered ? Icons.filter_alt : Icons.tune_rounded,
            color: Colors.white, size: 21),
        ),
      ),
    ]);
  }
}
