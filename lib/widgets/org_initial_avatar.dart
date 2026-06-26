import 'package:flutter/material.dart';

/// Professional letter avatar for organizations without a logo image.
/// Displays the first letter of the org name on a colored background.
/// Used as fallback in NetImage across all org-related screens.
class OrgInitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool circular;

  const OrgInitialAvatar({
    super.key,
    required this.name,
    required this.size,
    this.circular = false,
  });

  Color _colorFromName(String name) {
    const colors = [
      Color(0xFF1565C0), // deep blue
      Color(0xFF2E7D32), // dark green
      Color(0xFF6A1B9A), // purple
      Color(0xFFE65100), // deep orange
      Color(0xFF00838F), // teal
      Color(0xFFC62828), // red
      Color(0xFF4527A0), // indigo
      Color(0xFF00695C), // green teal
      Color(0xFF558B2F), // light green
      Color(0xFF4E342E), // brown
    ];
    final index = name.isNotEmpty
        ? name.trim().codeUnitAt(0) % colors.length
        : 0;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';
    final bg = _colorFromName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * 0.18),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
