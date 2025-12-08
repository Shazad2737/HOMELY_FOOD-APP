import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_api/src/user/models/meal_type.dart' as user_models;

/// {@template order_item_card}
/// Widget displaying a single order item with food details in a compact card
/// {@endtemplate}
class OrderItemCard extends StatelessWidget {
  /// {@macro order_item_card}
  const OrderItemCard({required this.item, super.key});

  /// Order item to display
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final foodItem = item.foodItem;
    final mealType = item.mealType;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Image (left side)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: foodItem.imageUrl != null
                ? Image.network(
                    foodItem.imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          // Food Details (right side)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type Badge + Delivery Time Row
                  Row(
                    children: [
                      _buildMealTypeBadge(context, mealType),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${mealType.startTime} - ${mealType.endTime}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppColors.grey500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Food Name
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          foodItem.name +
                              (foodItem.code != null
                                  ? ' (${foodItem.code})'
                                  : ''),
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (foodItem.description != null) ...[
                    Text(
                      foodItem.description!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Cuisine & Style chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (foodItem.cuisine != null)
                        _buildChip(context, foodItem.cuisine!),
                      if (foodItem.style != null)
                        _buildChip(context, foodItem.style!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeBadge(
    BuildContext context,
    user_models.MealType mealType,
  ) {
    final config = _getMealConfig(mealType.type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.iconColor),
          const SizedBox(width: 3),
          Text(
            mealType.name,
            style: context.textTheme.labelSmall?.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  _MealConfig _getMealConfig(user_models.MealTypeEnum type) {
    switch (type) {
      case user_models.MealTypeEnum.breakfast:
        return const _MealConfig(
          icon: Icons.wb_sunny_outlined,
          backgroundColor: Color(0xFFFFF3E0),
          iconColor: Color(0xFFE65100),
          textColor: Color(0xFFE65100),
        );
      case user_models.MealTypeEnum.lunch:
        return const _MealConfig(
          icon: Icons.light_mode_outlined,
          backgroundColor: Color(0xFFE3F2FD),
          iconColor: Color(0xFF1565C0),
          textColor: Color(0xFF1565C0),
        );
      case user_models.MealTypeEnum.dinner:
        return const _MealConfig(
          icon: Icons.nightlight_round_outlined,
          backgroundColor: Color(0xFFF3E5F5),
          iconColor: Color(0xFF6A1B9A),
          textColor: Color(0xFF6A1B9A),
        );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.grey200,
      child: const Center(
        child: Icon(Icons.restaurant, size: 32, color: AppColors.grey400),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _MealConfig {
  const _MealConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
}
