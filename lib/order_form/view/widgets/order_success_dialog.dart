import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:intl/intl.dart';

/// {@template order_success_dialog}
/// Dialog shown after successful order creation
/// {@endtemplate}
class OrderSuccessDialog extends StatelessWidget {
  /// {@macro order_success_dialog}
  const OrderSuccessDialog({
    required this.order,
    required this.mealSelections,
    required this.nextAvailableDateLabel,
    required this.showRepeatButton,
    required this.onOrderNextAvailable,
    required this.onViewDetails,
    this.onRepeatForNextAvailable,
    super.key,
  });

  /// The created order
  final CreateOrderResponse order;

  /// Meal selections (to show delivery locations - API doesn't return them)
  final Map<MealType, OrderItemSelection?> mealSelections;

  /// Label for the next available date (e.g., "Tomorrow", "Nov 6")
  final String nextAvailableDateLabel;

  /// Whether to show the repeat order button
  final bool showRepeatButton;

  /// Callback when user wants to repeat order for next available date
  final VoidCallback? onRepeatForNextAvailable;

  /// Callback when user wants to order next available date (fresh)
  final VoidCallback onOrderNextAvailable;

  /// Callback when user wants to view order details
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Order Confirmed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Order Number
            Text(
              'Order #${order.orderNumber}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Order Date
            Text(
              _formatOrderDate(order.orderDate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),

            // Order Items Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in order.orderItems) ...[
                    _OrderItemRow(
                      item: item,
                      mealSelections: mealSelections,
                    ),
                    if (item != order.orderItems.last)
                      const Divider(height: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Primary Action - Repeat Order (only if next date is available)
            if (showRepeatButton && onRepeatForNextAvailable != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRepeatForNextAvailable,
                  child: Text('Repeat Order for $nextAvailableDateLabel'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Secondary Action - Order Next Available Date (New)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onOrderNextAvailable,
                child: Text(
                  showRepeatButton
                      ? 'Order $nextAvailableDateLabel (New)'
                      : 'Order $nextAvailableDateLabel',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tertiary Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrderDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.item,
    required this.mealSelections,
  });

  final OrderItem item;
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
                item.foodItem.name,
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
