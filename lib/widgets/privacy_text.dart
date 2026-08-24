import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// Shows [text] normally, or replaces with 'â€¢â€¢â€¢â€¢' when privacy mode is on.
class PrivacyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  const PrivacyText(this.text,
      {super.key, this.style, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hidden = SettingsController.to.privacyMode;
      return Text(hidden ? _mask(text) : text,
          style: style, textAlign: textAlign);
    });
  }

  String _mask(String s) {
    if (s.isEmpty) return s;
    final m = RegExp(r'^([A-Za-z\s:#]+)(.*)$').firstMatch(s);
    if (m != null && m.group(2)!.isNotEmpty) {
      return '${m.group(1)}${'â€¢' * m.group(2)!.length.clamp(4, 8)}';
    }
    return 'â€¢' * s.length.clamp(4, 8);
  }
}

/// Overlays a blur/shield when privacy mode is active.
class PrivacyBlur extends StatelessWidget {
  final Widget child;
  const PrivacyBlur({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!SettingsController.to.privacyMode) return child;
      return Stack(children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: Icon(Icons.visibility_off_outlined,
                  color: Colors.white60, size: 26),
            ),
          ),
        ),
      ]);
    });
  }
}
