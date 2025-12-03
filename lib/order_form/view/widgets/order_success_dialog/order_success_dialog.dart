import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/order_success_dialog/widgets/order_item_row.dart';
import 'package:instamess_app/order_form/view/helpers/date_formatter.dart';

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
    required this.onViewAllOrders,
    this.onCloseSelectNextAvailable,
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

  /// Callback when user wants to view all orders
  final VoidCallback onViewAllOrders;

  /// Callback when user closes the dialog — should select next available date
  /// without any other navigation. If null, Close just pops the dialog.
  final VoidCallback? onCloseSelectNextAvailable;

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
              OrderFormDateFormatter.formatFullOrderDate(order.orderDate),
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
                    OrderItemRow(
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

            // both of these actions are commented out for now as client
            // requested simpler dialog with just view orders and close options.
            // we are keeping the code here for future reference.

            // // Primary Action - Repeat Order (only if next date is available)
            // if (showRepeatButton && onRepeatForNextAvailable != null) ...[
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: onRepeatForNextAvailable,
            //       child: Text('Repeat Order for $nextAvailableDateLabel'),
            //     ),
            //   ),
            //   const SizedBox(height: 12),
            // ],

            // // Secondary Action - Order Next Available Date (New)
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     onPressed: onOrderNextAvailable,
            //     child: Text(
            //       showRepeatButton
            //           ? 'Order $nextAvailableDateLabel (New)'
            //           : 'Order $nextAvailableDateLabel',
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),

            // // Tertiary Actions
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     TextButton(
            //       onPressed: onViewAllOrders,
            //       child: const Text('View all orders'),
            //     ),
            //     TextButton(
            //       onPressed: () => Navigator.of(context).pop(),
            //       child: const Text('Close'),
            //     ),
            //   ],
            // ),

            // new layout with primary close action and
            //secondary view orders action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onCloseSelectNextAvailable ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onViewAllOrders,
              child: const Text('View all orders'),
            ),
          ],
        ),
      ),
    );
  }
}
