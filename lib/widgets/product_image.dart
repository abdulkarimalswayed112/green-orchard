import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Fruit / product photos from the API's `image_url` (FR10 image handling):
///  - cached on the device, so scrolling back doesn't re-download
///  - soft green placeholder with a spinner while loading
///  - leaf icon if the URL is missing or the image fails
class ProductImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 14,
    this.fit = BoxFit.cover,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: hasUrl
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 250),
                placeholder: (_, __) => Container(
                  color: AppColors.leafTint,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.leaf),
                  ),
                ),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.leafTint,
        alignment: Alignment.center,
        child: Icon(Icons.eco_rounded, color: AppColors.leaf, size: iconSize),
      );
}
