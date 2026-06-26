// web_img.dart — Web-only image widget using native <img> HTML element.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Registers the img view factory once per image URL.
/// Uses the browser's native <img> which loads without CORS restriction.
class WebImg extends StatefulWidget {
  final String   url;
  final double?  width;
  final double?  height;
  final BoxFit   fit;
  final Widget?  fallback;

  const WebImg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  State<WebImg> createState() => _WebImgState();
}

class _WebImgState extends State<WebImg> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'web-img-${widget.url.hashCode}';
    _register();
  }

  void _register() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        final imgEl = html.ImageElement()
          ..src = widget.url
          ..style.width  = '100%'
          ..style.height = '100%'
          ..style.objectFit = _fitCss(widget.fit)
          ..style.display = 'block';
        return imgEl;
      });
    } catch (_) {
      // Already registered — safe to ignore
    }
  }

  String _fitCss(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:   return 'contain';
      case BoxFit.fill:      return 'fill';
      case BoxFit.fitWidth:  return 'contain';
      case BoxFit.fitHeight: return 'contain';
      case BoxFit.none:      return 'none';
      case BoxFit.scaleDown: return 'scale-down';
      case BoxFit.cover:
      default:               return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
