import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global snackbar helper â€” truncates long messages to prevent overflow.
void showSnack(
  String title,
  String message, {
  bool isError = false,
  Color? bgColor,
  Color? textColor,
  Duration duration = const Duration(seconds: 3),
}) {
  const _green = Color(0xFF2C5F4F);
  final display =
      message.length > 150 ? '\${message.substring(0, 150)}â€¦' : message;
  Get.snackbar(
    title,
    display,
    snackPosition: SnackPosition.TOP,
    backgroundColor:
        bgColor ?? (isError ? Colors.red[50] : _green.withValues(alpha: 0.12)),
    colorText: textColor ?? (isError ? Colors.red[800] : _green),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: duration,
    isDismissible: true,
    messageText: Text(
      display,
      style: TextStyle(
          fontSize: 13,
          color: textColor ?? (isError ? Colors.red[800] : _green)),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
