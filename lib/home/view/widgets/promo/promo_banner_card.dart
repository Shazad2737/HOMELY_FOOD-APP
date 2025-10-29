import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class PromoBanner {
  PromoBanner({
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
    this.image,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final Widget? image;

  final Color? backgroundColor;
}

/// A promotional banner card with gradient background and CTA button.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({
    required this.promoBanner,
    super.key,
  });

  final PromoBanner promoBanner;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: promoBanner.backgroundColor ?? AppColors.appRed,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative blurred ellipse behind title
            Positioned(
              left: -18,
              top: -34,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 2),
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffaa2a58).withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF334077).withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          promoBanner.title,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        // const SizedBox(height: 6),
                        Text(
                          promoBanner.subtitle,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (promoBanner.buttonLabel != null) ...[
                          const SizedBox(height: 6),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              // backgroundColor: AppColors.white,
                              foregroundColor: AppColors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 12,
                              ),
                              textStyle: context.textTheme.bodySmall?.semiBold,
                            ),
                            onPressed: promoBanner.onPressed,
                            child: Text(promoBanner.buttonLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (promoBanner.image != null) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 96,
                      width: 120,
                      child: FittedBox(child: promoBanner.image),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
