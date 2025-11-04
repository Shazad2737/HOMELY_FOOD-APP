import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/orders/view/widgets/info_row.dart';

/// {@template order_item_card}
/// Widget displaying a single order item with food details
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food Image
        if (foodItem.imageUrl != null)
          Image.network(
            foodItem.imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: AppColors.grey200,
                child: const Icon(Icons.restaurant, size: 48),
              );
            },
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.restaurant, size: 48),
            ),
          ),
        const SizedBox(height: 16),
        // Food Name
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodItem.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Description with icon
              if (foodItem.description != null) ...[
                InfoRow(
                  icon: Icons.restaurant,
                  text: foodItem.description!,
                ),
                const SizedBox(height: 8),
              ],
              // Cuisine
              if (foodItem.cuisine != null) ...[
                InfoRow(
                  icon: Icons.set_meal_outlined,
                  text: 'Cuisine: ${foodItem.cuisine}',
                ),
                const SizedBox(height: 8),
              ],
              // Style
              if (foodItem.style != null) ...[
                InfoRow(
                  icon: Icons.style_outlined,
                  text: 'Style: ${foodItem.style}',
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              // Delivery Time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delivery_dining,
                      color: AppColors.appGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delivery is scheduled between ${mealType.startTime} and ${mealType.endTime}.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.appGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
