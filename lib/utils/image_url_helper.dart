import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../services/api_constants.dart';

/// ImageUrlHelper — fixes server URLs for each platform.
///
/// Django returns: "http://127.0.0.1:8000/media/..."
///
/// Platform mapping:
///   Web (Chrome)        → http://127.0.0.1:8000  (browser talks to localhost directly)
///   Android Emulator    → http://10.0.2.2:8000   (loopback alias to host)
///   iOS Simulator       → http://127.0.0.1:8000
///   Real Device         → http://192.168.x.x:8000 (set in ApiConstants.baseUrl)
///   Desktop             → http://127.0.0.1:8000
class ImageUrlHelper {
  ImageUrlHelper._();

  static String fix(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();

    // Already HTTPS (CDN / production) — don't touch
    if (trimmed.startsWith('https://')) return trimmed;

    // Relative path like /media/... → prepend base URL
    if (trimmed.startsWith('/')) {
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
      final fixed = '$base$trimmed';
      debugPrint('🖼 fix(rel): $url → $fixed');
      return fixed;
    }

    // http://any-host:port/... → replace host:port with platform-correct base
    if (trimmed.startsWith('http://')) {
      final base  = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
      final fixed = trimmed.replaceFirst(RegExp(r'^http://[^/]+'), base);
      debugPrint('🖼 fix(abs): $url → $fixed');
      return fixed;
    }

    return trimmed;
  }

  static bool isValid(String? url) {
    final f = fix(url);
    return f.isNotEmpty && (f.startsWith('http://') || f.startsWith('https://'));
  }
}
