import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// A pill-shaped chip for food categories.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final background =
        selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white;
    final borderColor = selected ? AppColors.primary : AppColors.border;
    final textColor = selected ? AppColors.primary : AppColors.grey700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
