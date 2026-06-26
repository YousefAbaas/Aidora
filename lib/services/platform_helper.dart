// platform_helper.dart
// ─────────────────────────────────────────────────────────────────────────────
// Conditional import:
//   • On Web   → loads platform_helper_stub.dart  (no dart:io)
//   • On Native → loads platform_helper_io.dart   (uses dart:io)
//
// This is the CORRECT Flutter pattern for cross-platform code that needs
// dart:io on native but must compile on web without it.
// ─────────────────────────────────────────────────────────────────────────────
export 'platform_helper_stub.dart'
    if (dart.library.io) 'platform_helper_io.dart';
