import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// IconMapper
/// Converts the icon string returned by Django (e.g. "shield", "school")
/// into a Flutter [IconData].
///
/// Add more entries here as the backend introduces new icon names.
/// ─────────────────────────────────────────────────────────────────────────────
class IconMapper {
  IconMapper._();

  static const Map<String, IconData> _map = {
    'shield':            Icons.shield,
    'school':            Icons.school,
    'water_drop':        Icons.water_drop,
    'restaurant':        Icons.restaurant,
    'home':              Icons.home,
    'emergency':         Icons.emergency,
    'local_shipping':    Icons.local_shipping,
    'vaccines':          Icons.vaccines,
    'gavel':             Icons.gavel,
    'medical_services':  Icons.medical_services,
    'health_and_safety': Icons.health_and_safety,
    'psychology':        Icons.psychology,
    'coronavirus':       Icons.coronavirus,
    'pregnant_woman':    Icons.pregnant_woman,
    'security':          Icons.security,
    'volunteer_activism':Icons.volunteer_activism,
    'people':            Icons.people,
    'food_bank':         Icons.food_bank,
    'help_outline':      Icons.help_outline,
    'info':              Icons.info,
  };

  static const Map<String, Color> _colorMap = {
    'shield':            Color(0xFF1565C0),
    'school':            Color(0xFFF57C00),
    'water_drop':        Color(0xFF0277BD),
    'restaurant':        Color(0xFFE65100),
    'home':              Color(0xFF4527A0),
    'emergency':         Color(0xFFC62828),
    'local_shipping':    Color(0xFF00695C),
    'vaccines':          Color(0xFF2E7D32),
    'gavel':             Color(0xFF37474F),
    'medical_services':  Color(0xFFD32F2F),
    'health_and_safety': Color(0xFF2E7D32),
    'psychology':        Color(0xFF6A1B9A),
    'coronavirus':       Color(0xFFF57C00),
    'pregnant_woman':    Color(0xFFAD1457),
    'security':          Color(0xFF4527A0),
  };

  static IconData get(String iconName) =>
      _map[iconName] ?? Icons.help_outline;

  static Color getColor(String iconName) =>
      _colorMap[iconName] ?? const Color(0xFF2C5F4F);
}
