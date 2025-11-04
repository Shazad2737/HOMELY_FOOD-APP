import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';

/// Individual food item tile in the selection list
class FoodItemTile extends StatelessWidget {
  /// Constructor
  const FoodItemTile({
    required this.foodItem,
    required this.mealType,
    required this.onSelected,
    super.key,
  });

  /// The food item to display
  final FoodItem foodItem;

  /// The meal type this food belongs to
  final MealType mealType;

  /// Callback when food is selected
  final void Function(FoodItem) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        final selection = state.mealSelections[mealType];
        final isSelected = selection?.food.id == foodItem.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppColors.appGreen, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: () => onSelected(foodItem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food image
                  _buildImage(context),

                  // Food details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title, code, and selection indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${foodItem.name} (${foodItem.code})',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.appGreen,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        if (foodItem.description != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  foodItem.description!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Cuisine
                        if (foodItem.cuisine != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cuisine: ${foodItem.cuisine!.displayName}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Style
                        if (foodItem.style != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.set_meal_outlined,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Style: ${foodItem.style!.displayName}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Dietary badges and price
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (foodItem.isVegetarian)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      size: 14,
                                      color: AppColors.appGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Veg',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            if (foodItem.isVegetarian && foodItem.isVegan)
                              const SizedBox(width: 8),
                            if (foodItem.isVegan)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.park,
                                      size: 14,
                                      color: AppColors.appGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vegan',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Delivery mode info
                        if (foodItem.deliveryMode == DeliveryMode.withOther &&
                            foodItem.deliverWith != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.info,
                                ),
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
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
}
