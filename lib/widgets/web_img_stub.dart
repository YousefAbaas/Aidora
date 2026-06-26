// web_img_stub.dart — Non-web stub. Never actually used on native platforms.
import 'package:flutter/material.dart';

class WebImg extends StatelessWidget {
  final String  url;
  final double? width;
  final double? height;
  final BoxFit  fit;
  final Widget? fallback;

  const WebImg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) => fallback ?? const SizedBox.shrink();
}
