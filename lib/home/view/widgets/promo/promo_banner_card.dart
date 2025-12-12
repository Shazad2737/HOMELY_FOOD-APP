import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class PromoBanner {
  PromoBanner({
    required this.imageUrl,
    this.onTap,
  });

  final String imageUrl;
  final VoidCallback? onTap;
}

/// A promotional banner card displaying only an image with click functionality.
///
/// This card is designed to handle any image size or aspect ratio without
/// breaking the layout. The entire card is tappable when [onTap] is provided.
///
/// If [aspectRatio] is provided, the card will maintain that aspect ratio.
/// Otherwise, it adapts to fill the available space naturally.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({
    required this.promoBanner,
    this.aspectRatio,
    super.key,
  });

  final PromoBanner promoBanner;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.network(
      promoBanner.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return ColoredBox(
          color: AppColors.grey100,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: AppColors.grey100,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: AppColors.grey400,
            ),
          ),
        );
      },
    );

    return GestureDetector(
      onTap: promoBanner.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: aspectRatio != null
            ? AspectRatio(
                aspectRatio: aspectRatio!,
                child: imageWidget,
              )
            : imageWidget,
      ),
    );
  }
}
