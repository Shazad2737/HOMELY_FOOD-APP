import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/homely_api.dart' as ia;
import 'package:homely_app/router/utils/banner_navigation_handler.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({
    required this.banner,
    super.key,
  });

  final ia.Banner banner;

  @override
  Widget build(BuildContext context) {
    final image = banner.images.isNotEmpty ? banner.images.first : null;
    final imageUrl = image?.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final radius = BorderRadius.circular(16);

    return GestureDetector(
      onTap: () => BannerNavigationHandler.handleBannerTap(
        context.router,
        image?.redirectUrl,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _AdaptiveBannerImage(
          imageUrl: imageUrl,
          borderRadius: radius,
        ),
      ),
    );
  }
}

/// A banner image that adapts its height to the intrinsic image aspect ratio
/// while always expanding to the available width.
class _AdaptiveBannerImage extends StatefulWidget {
  const _AdaptiveBannerImage({
    required this.imageUrl,
    required this.borderRadius,
  });

  final String imageUrl;
  final BorderRadius borderRadius;

  @override
  State<_AdaptiveBannerImage> createState() => _AdaptiveBannerImageState();
}

class _AdaptiveBannerImageState extends State<_AdaptiveBannerImage> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  double? _aspectRatio; // width / height

  // Provide a sensible default while loading (typical banner ratio)
  static const double _fallbackAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _AdaptiveBannerImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _aspectRatio = null;
      _unsubscribeImageStream();
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = CachedNetworkImageProvider(widget.imageUrl);
    final stream = provider.resolve(const ImageConfiguration());
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener(
      (imageInfo, _) {
        final width = imageInfo.image.width.toDouble();
        final height = imageInfo.image.height.toDouble();
        if (width > 0 && height > 0) {
          setState(() => _aspectRatio = width / height);
        }
      },
      onError: (_, __) {
        // Keep fallback aspect ratio on error
      },
    );
    stream.addListener(_imageStreamListener!);
  }

  void _unsubscribeImageStream() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  @override
  void dispose() {
    _unsubscribeImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final ar = _aspectRatio ?? _fallbackAspectRatio;
        final targetHeight = maxWidth / ar;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: targetHeight,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      },
    );
  }
}
