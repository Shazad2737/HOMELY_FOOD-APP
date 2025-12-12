import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/view/widgets/food_card/food_image.dart';
import 'package:instamess_app/menu/view/widgets/info_row.dart';
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
                  // Food image with veg badge and delivery mode badge
                  FoodImage(
                    foodItem: foodItem,
                    showDeliveryModeBadge: true,
                  ),

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
                        if (foodItem.description != null &&
                            foodItem.description!.isNotEmpty)
                          InfoRow(
                            icon: Icons.restaurant,
                            text: foodItem.description!,
                            iconColor: AppColors.appRed,
                          ),

                        // Cuisine
                        if (foodItem.cuisine != null &&
                            foodItem.cuisine!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          InfoRow(
                            icon: Icons.location_on_outlined,
                            text: 'Cuisine: ${foodItem.cuisine}',
                            iconColor: AppColors.appRed,
                          ),
                        ],

                        // Style
                        if (foodItem.style != null) ...[
                          const SizedBox(height: 4),
                          InfoRow(
                            icon: Icons.set_meal_outlined,
                            text: 'Style: ${foodItem.style}',
                            iconColor: AppColors.appRed,
                          ),
                        ],

                        // Vegan badge (veg badge is now on image)
                        if (foodItem.isVegan) ...[
                          const SizedBox(height: 12),
                          _VeganBadge(),
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
}

/// Badge for vegan food items
class _VeganBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
