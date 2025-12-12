import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/homely_api.dart';

/// Displays dietary badges for a food item (currently only vegan badge).
class DietaryBadges extends StatelessWidget {
  const DietaryBadges({
    required this.foodItem,
    super.key,
  });

  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (foodItem.isVegan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.appGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.park, size: 14, color: AppColors.appGreen),
                const SizedBox(width: 4),
                Text(
                  'Vegan',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.appGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
