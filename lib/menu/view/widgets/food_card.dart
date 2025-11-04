import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/view/widgets/day_chip.dart';
import 'package:instamess_app/menu/view/widgets/info_row.dart';

/// Food item card showing dish details
class MenuFoodCard extends StatelessWidget {
  const MenuFoodCard({
    required this.foodItem,
    super.key,
  });

  final FoodItem foodItem;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image with favorite button
          _buildImage(context),

          // Food details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and code
                Text(
                  '${foodItem.name} (${foodItem.code})',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                if (foodItem.description != null) ...[
                  InfoRow(
                    icon: Icons.restaurant,
                    text: foodItem.description!,
                    iconColor: AppColors.appRed,
                  ),
                ],

                // Cuisine
                if (foodItem.cuisine != null)
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: 'Cuisine: ${foodItem.cuisine!.displayName}',
                    iconColor: AppColors.appRed,
                  ),

                // Style
                if (foodItem.style != null)
                  InfoRow(
                    icon: Icons.set_meal_outlined,
                    text: 'Style: ${foodItem.style!.displayName}',
                    iconColor: AppColors.appRed,
                  ),

                // Dietary badges
                const SizedBox(height: 12),
                _buildDietaryBadges(context),

                // Delivery mode info
                if (foodItem.deliveryMode == DeliveryMode.withOther &&
                    foodItem.deliverWith != null) ...[
                  const SizedBox(height: 12),
                  _buildDeliveryInfo(context),
                ],

                // Price
                if (foodItem.price != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'AED ${foodItem.price!.toStringAsFixed(2)}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.appOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Days availability
                Row(
                  spacing: 8,
                  children: DayOfWeek.values.map((day) {
                    final isAvailable = foodItem.isAvailableOn(day);
                    return DayChip(
                      label: day.shortName,
                      isAvailable: isAvailable,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: (foodItem.imageUrl != null)
          ? CachedNetworkImage(
              imageUrl: foodItem.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(
                color: AppColors.grey200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: AppColors.grey200,
      child: Icon(
        Icons.restaurant_menu,
        size: 64,
        color: AppColors.grey500,
      ),
    );
  }

  Widget _buildDietaryBadges(BuildContext context) {
    return Row(
      children: [
        if (foodItem.isVegetarian)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.appGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 14, color: AppColors.appGreen),
                const SizedBox(width: 4),
                Text(
                  'Veg',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.appGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (foodItem.isVegetarian && foodItem.isVegan) const SizedBox(width: 8),
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

  Widget _buildDeliveryInfo(BuildContext context) {
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
