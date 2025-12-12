import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// A pill-shaped chip for food categories.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.image,
    required this.width,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  final String label;

  final ImageProvider image;
  final VoidCallback? onTap;

  final double width;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const background = AppColors.white;
    final borderColor = isSelected ? AppColors.appOrange : AppColors.border;
    final textColor = isSelected ? AppColors.appOrange : AppColors.grey700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    blurRadius: 8,
                    color: AppColors.appOrange.withValues(alpha: 0.3),
                  ),
                ]
              : const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color.fromARGB(65, 191, 202, 255),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  // color: AppColors.appBarIcon,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const Space(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.semiBold.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
