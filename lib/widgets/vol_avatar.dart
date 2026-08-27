import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vol_controller.dart';
import '../utils/image_url_helper.dart';

/// Reactive volunteer avatar â€” mirrors ProfileAvatar pattern for refugees.
class VolAvatar extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color borderColor;

  const VolAvatar({
    super.key,
    this.size = 44,
    this.borderWidth = 0,
    this.borderColor = const Color(0xFF2C5F4F),
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = VolController.to.volImageUrl.value;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          color: Colors.grey[200],
        ),
        child: ClipOval(child: _imageWidget(url)),
      );
    });
  }

  Widget _imageWidget(String url) {
    if (url.isEmpty) return _defaultAvatar();

    final fixed = ImageUrlHelper.fix(url);
    if (fixed.isEmpty) return _defaultAvatar();

    // Web: use Image.network (browser handles CORS)
    return Image.network(
      fixed,
      key: ValueKey(fixed),
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _defaultAvatar(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _shimmer(),
    );
  }

  Widget _shimmer() => Container(
        color: Colors.grey[200],
        child: Center(
            child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: const CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF2C5F4F)),
        )),
      );

  Widget _defaultAvatar() => Container(
        color: Colors.grey[200],
        child: Image.asset(
          'img/profile_avatar.jpg',
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(Icons.person_rounded,
              size: size * 0.55, color: Colors.grey[400]),
        ),
      );
}
