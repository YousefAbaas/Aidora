import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/org_controller.dart';
import '../utils/image_url_helper.dart';

/// Reactive org logo avatar — mirrors ProfileAvatar pattern for refugees.
/// Auto-updates via Obx when OrgController.orgLogoUrl changes.
class OrgLogoAvatar extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color  borderColor;

  const OrgLogoAvatar({
    super.key,
    this.size        = 40,
    this.borderWidth = 0,
    this.borderColor = const Color(0xFF2C5F4F),
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final oc  = OrgController.to;
      final url = oc.orgLogoUrl.value;

      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          color: Colors.grey[100],
        ),
        child: ClipOval(child: _imageWidget(url)),
      );
    });
  }

  Widget _imageWidget(String url) {
    if (url.isEmpty) return _defaultIcon();

    final fixed = ImageUrlHelper.fix(url);
    if (fixed.isEmpty) return _defaultIcon();

    return Image.network(
      fixed,
      key:    ValueKey(fixed),
      fit:    BoxFit.cover,
      width:  size,
      height: size,
      errorBuilder:   (_, __, ___) => _defaultIcon(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _shimmer(),
    );
  }

  Widget _shimmer() => Container(
    color: Colors.grey[200],
    child: Center(child: SizedBox(
      width: size * 0.35, height: size * 0.35,
      child: const CircularProgressIndicator(
          strokeWidth: 2, color: Color(0xFF2C5F4F)),
    )),
  );

  Widget _defaultIcon() => Container(
    color: Colors.grey[100],
    child: Icon(Icons.business_rounded,
        size: size * 0.55, color: const Color(0xFF2C5F4F)),
  );
}
