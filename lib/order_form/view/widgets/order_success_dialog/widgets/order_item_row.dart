import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';

/// Single order item row in success dialog
class OrderItemRow extends StatelessWidget {
  /// Constructor
  const OrderItemRow({
    required this.item,
    required this.mealSelections,
    super.key,
  });

  /// The order item
  final OrderItem item;

  /// Meal selections (to show delivery locations)
  final Map<MealType, OrderItemSelection?> mealSelections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find delivery location from meal selections (workaround for API not returning it)
    var deliveryLocation = item.deliveryLocation;
    if (deliveryLocation == null) {
      // Try to find from meal selections
      final mealTypeMatch = _findMatchingMealType(item.mealType.type);
      final selection = mealTypeMatch != null
          ? mealSelections[mealTypeMatch]
          : null;
      deliveryLocation = selection?.location;
    }

    return Row(
      children: [
        // Meal Type Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getMealTypeColor(item.mealType.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMealTypeIcon(item.mealType.type),
            size: 18,
            color: _getMealTypeColor(item.mealType.type),
          ),
        ),
        const SizedBox(width: 12),

        // Food Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.foodItem.name +
                    ((item.foodItem.code?.isNotEmpty ?? false)
                        ? ' ${item.foodItem.code!}'
                        : ''),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                item.mealType.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              if (deliveryLocation != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        deliveryLocation.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey400,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Matches API meal type enum to MealType enum from meal selections
  MealType? _findMatchingMealType(MealTypeEnum apiMealType) {
    // Try to find a matching meal type in selections by comparing enum values
    for (final mealType in mealSelections.keys) {
      if (mealType.name.toLowerCase() == apiMealType.name.toLowerCase()) {
        return mealType;
      }
    }
    return null;
  }

  IconData _getMealTypeIcon(MealTypeEnum type) {
    switch (type) {
      case MealTypeEnum.breakfast:
        return Icons.free_breakfast;
      case MealTypeEnum.lunch:
        return Icons.lunch_dining;
      case MealTypeEnum.dinner:
        return Icons.dinner_dining;
    }
  }

  Color _getMealTypeColor(MealTypeEnum type) {
    switch (type) {
      case MealTypeEnum.breakfast:
        return AppColors.appOrange;
      case MealTypeEnum.lunch:
        return AppColors.appGreen;
      case MealTypeEnum.dinner:
        return AppColors.info;
    }
  }
}
