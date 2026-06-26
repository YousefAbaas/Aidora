import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import '../utils/image_url_helper.dart';

// Conditional import: web_img.dart on web, stub on native
import 'web_img_stub.dart'
    if (dart.library.html) 'web_img.dart';

/// NetImage — cross-platform image widget.
///
/// ┌────────────────────────────────────────────────────────────┐
/// │ Platform │ Loader                         │ CORS           │
/// ├──────────┼────────────────────────────────┼────────────────┤
/// │ Web      │ HtmlElementView(<img>)         │ Not blocked ✅  │
/// │ Native   │ CachedNetworkImage             │ N/A            │
/// │ File     │ Image.file                     │ N/A            │
/// └────────────────────────────────────────────────────────────┘
class NetImage extends StatelessWidget {
  final String?      url;
  final BoxFit       fit;
  final double?      width;
  final double?      height;
  final Widget?      fallback;
  final BorderRadius? borderRadius;
  final bool         bustCache;

  const NetImage({
    super.key,
    required this.url,
    this.fit         = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
    this.borderRadius,
    this.bustCache   = false,
  });

  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    if (raw.isEmpty) return _wrap(_fallback());

    // ── Local file (native only) ──────────────────────────────────────────────
    if (!kIsWeb && !raw.startsWith('http')) {
      try {
        return _wrap(Image.file(File(raw),
            key: ValueKey(raw), fit: fit, width: width, height: height,
            errorBuilder: (_, __, ___) => _fallback()));
      } catch (_) { return _wrap(_fallback()); }
    }

    final fixed = ImageUrlHelper.fix(raw);
    if (fixed.isEmpty) return _wrap(_fallback());

    // ── Web: native HTML <img> — bypasses Flutter XHR / CORS completely ───────
    if (kIsWeb) {
      final imgUrl = bustCache
          ? '$fixed${fixed.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch ~/ 60000}'
          : fixed;

      return _wrap(WebImg(
        url:      imgUrl,
        width:    width,
        height:   height,
        fit:      fit,
        fallback: _fallback(),
      ));
    }

    // ── Native: CachedNetworkImage ─────────────────────────────────────────────
    final cacheKey = bustCache
        ? '$fixed?t=${DateTime.now().millisecondsSinceEpoch ~/ 60000}'
        : fixed;

    // ngrok adds an interstitial "browser warning" page for non-browser requests.
    // The header 'ngrok-skip-browser-warning' bypasses it for media/image requests.
    final headers = fixed.contains('ngrok')
        ? {'ngrok-skip-browser-warning': 'true', 'User-Agent': 'AidoraApp/1.0'}
        : <String, String>{};

    return _wrap(CachedNetworkImage(
      imageUrl:      fixed,
      key:           ValueKey(cacheKey),
      width:         width,
      height:        height,
      fit:           fit,
      httpHeaders:   headers,
      memCacheWidth:  width  != null ? (width!  * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      placeholder: (_, __) => _shimmer(),
      errorWidget: (_, u, e) {
        debugPrint('📱 CachedImg error [$u]: $e');
        return _fallback();
      },
    ));
  }

  Widget _wrap(Widget child) => borderRadius != null
      ? ClipRRect(borderRadius: borderRadius!, child: child)
      : child;

  Widget _shimmer() => Container(
      width: width, height: height, color: Colors.grey[200],
      child: Center(child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: const Color(0xFF2C5F4F)))));

  Widget _fallback() => fallback ?? Container(
      width: width, height: height, color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_rounded,
          size: (width ?? 48) * 0.4, color: Colors.grey[400]));
}
