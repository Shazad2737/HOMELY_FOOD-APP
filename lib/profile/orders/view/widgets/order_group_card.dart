import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_api/src/user/models/meal_type.dart' as user_models;
import 'package:instamess_app/profile/orders/view/widgets/order_item_card.dart';
import 'package:intl/intl.dart';

/// {@template order_group_card}
/// Widget displaying an order group with header and items grouped by meal type
/// {@endtemplate}
class OrderGroupCard extends StatelessWidget {
  /// {@macro order_group_card}
  const OrderGroupCard({required this.orderGroup, super.key});

  /// Order group to display
  final OrderGroup orderGroup;

  @override
  Widget build(BuildContext context) {
    final order = orderGroup.orders.first;
    final groupedItems = _groupAndSortByMealType(order.orderItems);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          _buildDateHeader(context, order),
          // Order info bar
          _buildOrderInfoBar(context, order),
          // Grouped meal items
          ...groupedItems.entries.map(
            (entry) => _buildMealSection(context, entry.key, entry.value),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, Order order) {
    final formattedDate = _formatDatePretty(order.orderDate);
    final dayOfWeek = _getDayOfWeek(order.orderDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.appRed,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayOfWeek,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formattedDate,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoBar(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 16,
            color: AppColors.grey600,
          ),
          const SizedBox(width: 6),
          Text(
            order.orderNumber,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _buildStatusBadge(context, order.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OrderStatus.confirmed:
        bgColor = AppColors.appGreen.withOpacity(0.15);
        textColor = AppColors.appGreen;
      case OrderStatus.delivered:
        bgColor = AppColors.info.withOpacity(0.15);
        textColor = AppColors.info;
      case OrderStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    user_models.MealTypeEnum mealType,
    List<OrderItem> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items for this meal type (meal badge is now on each item card)
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: OrderItemCard(item: item),
            ),
          ),
        ],
      ),
    );
  }

  /// Groups order items by meal type and sorts them in breakfast -> lunch -> dinner order
  Map<user_models.MealTypeEnum, List<OrderItem>> _groupAndSortByMealType(
    List<OrderItem> items,
  ) {
    final grouped = <user_models.MealTypeEnum, List<OrderItem>>{};

    for (final item in items) {
      final type = item.mealType.type;
      grouped.putIfAbsent(type, () => []).add(item);
    }

    // Sort by meal type priority
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => _mealTypePriority(a).compareTo(_mealTypePriority(b)));

    return {
      for (final key in sortedKeys) key: grouped[key]!,
    };
  }

  int _mealTypePriority(user_models.MealTypeEnum type) {
    switch (type) {
      case user_models.MealTypeEnum.breakfast:
        return 0;
      case user_models.MealTypeEnum.lunch:
        return 1;
      case user_models.MealTypeEnum.dinner:
        return 2;
    }
  }

  String _formatDatePretty(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getDayOfWeek(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE').format(date);
    } catch (e) {
      return '';
    }
  }
}
