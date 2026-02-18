import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zenslam/core/const/app_colors.dart';

/// Displays a thumbnail image from either a local asset path or a network URL.
/// Detects asset paths (starting with "assets/") and uses Image.asset,
/// otherwise falls back to CachedNetworkImage.
class ThumbnailImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const ThumbnailImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = Duration.zero,
    this.fadeOutDuration = Duration.zero,
    this.placeholder,
    this.errorWidget,
  });

  static bool isAssetPath(String path) =>
      path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (isAssetPath(imageUrl)) {
      return Image.asset(
        imageUrl,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) {
          if (errorWidget != null) {
            return errorWidget!(context, imageUrl, error);
          }
          return _defaultError();
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: imageUrl.isNotEmpty ? imageUrl : null,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: placeholder ?? (context, url) => _defaultPlaceholder(),
      errorWidget: errorWidget ?? (context, url, error) => _defaultError(),
    );
  }

  Widget _defaultPlaceholder() {
    return const Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      color: Colors.grey.shade800,
      child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
    );
  }
}
