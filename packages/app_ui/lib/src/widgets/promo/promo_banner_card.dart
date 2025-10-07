import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// A promotional banner card with gradient background and CTA button.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
    this.image,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (buttonLabel != null) ...[
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(buttonLabel!),
                  ),
                ],
              ],
            ),
          ),
          if (image != null) ...[
            const SizedBox(width: 16),
            SizedBox(height: 96, width: 120, child: FittedBox(child: image)),
          ],
        ],
      ),
    );
  }
}
