import 'package:flutter/foundation.dart' show debugPrint;
import '../services/api_constants.dart';

/// ImageUrlHelper â€” fixes server URLs for each platform.
///
/// Django returns: "http://127.0.0.1:8000/media/..."
///
/// Platform mapping:
///   Web (Chrome)        â†’ http://127.0.0.1:8000  (browser talks to localhost directly)
///   Android Emulator    â†’ http://10.0.2.2:8000   (loopback alias to host)
///   iOS Simulator       â†’ http://127.0.0.1:8000
///   Real Device         â†’ http://192.168.x.x:8000 (set in ApiConstants.baseUrl)
///   Desktop             â†’ http://127.0.0.1:8000
class ImageUrlHelper {
  ImageUrlHelper._();

  static String fix(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();

    // Already HTTPS (CDN / production) â€” don't touch
    if (trimmed.startsWith('https://')) return trimmed;

    // Relative path like /media/... â†’ prepend base URL
    if (trimmed.startsWith('/')) {
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
      final fixed = '$base$trimmed';
      debugPrint('ðŸ–¼ fix(rel): $url â†’ $fixed');
      return fixed;
    }

    // http://any-host:port/... â†’ replace host:port with platform-correct base
    if (trimmed.startsWith('http://')) {
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
      final fixed = trimmed.replaceFirst(RegExp(r'^http://[^/]+'), base);
      debugPrint('ðŸ–¼ fix(abs): $url â†’ $fixed');
      return fixed;
    }

    return trimmed;
  }

  static bool isValid(String? url) {
    final f = fix(url);
    return f.isNotEmpty &&
        (f.startsWith('http://') || f.startsWith('https://'));
  }
}
