import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

/// Displays delivery information badge for food items that are
/// delivered with other items.
class DeliveryInfoBadge extends StatelessWidget {
  const DeliveryInfoBadge({
    required this.foodItem,
    super.key,
  });

  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.info),
          const SizedBox(width: 6),
          Text(
            'Delivered with ${foodItem.deliverWith!.name}',
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
