import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/order_form/view/helpers/date_formatter.dart';
import 'package:homely_app/order_form/view/helpers/meal_type_helper.dart';

/// Shows context information (date and meal type) for food selection
class FoodSelectionHeader extends StatelessWidget {
  /// Constructor
  const FoodSelectionHeader({
    required this.mealType,
    required this.selectedDay,
    super.key,
  });

  /// The meal type being selected
  final MealType mealType;

  /// The selected day data
  final dynamic selectedDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select ${MealTypeHelper.getMealLabel(mealType)}',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDateContextChip(context),
        ],
      ),
    );
  }

  Widget _buildDateContextChip(BuildContext context) {
    if (selectedDay == null || selectedDay.date == null) {
      return const SizedBox.shrink();
    }

    final date = DateTime.parse(selectedDay.date as String);
    final formattedDate = OrderFormDateFormatter.formatCompactDate(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            formattedDate,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
