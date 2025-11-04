import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/orders/view/widgets/order_item_card.dart';
import 'package:intl/intl.dart';

/// {@template order_group_card}
/// Widget displaying an order group with header and items
/// {@endtemplate}
class OrderGroupCard extends StatelessWidget {
  /// {@macro order_group_card}
  const OrderGroupCard({required this.orderGroup, super.key});

  /// Order group to display
  final OrderGroup orderGroup;

  @override
  Widget build(BuildContext context) {
    // Assuming one order per group based on the design
    final order = orderGroup.orders.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.appRed,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Header with ID and Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.appRed,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${order.orderNumber}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.appRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Date: ${_formatDate(order.orderDate)}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.appRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Order Items
            ...order.orderItems.mapWithIndex(
              (OrderItem item, index) => Padding(
                padding: index == 0
                    ? const EdgeInsets.only()
                    : const EdgeInsets.only(top: 16, bottom: 8),
                child: OrderItemCard(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
