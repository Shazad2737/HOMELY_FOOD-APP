import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/food_selection_bottom_sheet.dart';

/// Card for selecting a meal type
class MealCard extends StatelessWidget {
  /// Constructor
  const MealCard({
    required this.mealType,
    required this.isAvailable,
    super.key,
  });

  /// The meal type
  final MealType mealType;

  /// Whether this meal is available for selected date
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      buildWhen: (previous, current) =>
          previous.mealSelections[mealType] != current.mealSelections[mealType],
      builder: (context, state) {
        final selection = state.mealSelections[mealType];
        final isSelected = selection != null;

        return GestureDetector(
          onTap: isAvailable ? () => _handleTap(context, state) : null,
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppColors.appGreen, width: 2)
                  : BorderSide.none,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(isSelected, isAvailable),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getMealIcon(mealType, isSelected, isAvailable),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMealLabel(mealType),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.appGreen,
                          size: 24,
                        )
                      else if (!isAvailable)
                        const Icon(
                          Icons.block,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSelectionDetails(context, selection),
                  ] else if (isAvailable) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to select',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Not available',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionDetails(
    BuildContext context,
    OrderItemSelection selection,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                selection.food.name,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (selection.food.description != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.restaurant,
                size: 16,
                color: AppColors.appRed,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  selection.food.description!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (selection.food.deliveryMode == DeliveryMode.withOther &&
            selection.food.deliverWith != null) ...[
          const SizedBox(height: 8),
          Container(
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
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.info,
                ),
                const SizedBox(width: 6),
                Text(
                  'Delivered with ${selection.food.deliverWith!.name}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else if (selection.food.deliveryMode == DeliveryMode.separate) ...[
          const SizedBox(height: 8),
          Container(
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
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.info,
                ),
                const SizedBox(width: 6),
                Text(
                  selection.location.displayName,
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
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isAvailable) {
    if (!isAvailable) return AppColors.grey50;
    if (isSelected) return AppColors.appGreen.withValues(alpha: 0.05);
    return AppColors.white;
  }

  Widget _getMealIcon(MealType type, bool isSelected, bool isAvailable) {
    final color = !isAvailable
        ? AppColors.grey500
        : (isSelected ? AppColors.appGreen : AppColors.appRed);
    IconData iconData;

    switch (type) {
      case MealType.breakfast:
        iconData = Icons.breakfast_dining;
      case MealType.lunch:
        iconData = Icons.lunch_dining;
      case MealType.dinner:
        iconData = Icons.dinner_dining;
    }

    return Icon(iconData, color: color, size: 28);
  }

  String _getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  void _handleTap(BuildContext context, OrderFormState state) {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return;

    // Find available food items for this meal type
    final availableDays = state.availableDaysState;
    if (!availableDays.isSuccess) return;

    final selectedDay = availableDays.maybeMap(
      success: (s) => s.data.days.firstWhere(
        (dynamic day) => day.date == selectedDate,
      ),
      orElse: () => null,
    );

    if (selectedDay == null) return;

    // Get food items based on meal type
    final foodItems = switch (mealType) {
      MealType.breakfast => selectedDay.foodItems.breakfast,
      MealType.lunch => selectedDay.foodItems.lunch,
      MealType.dinner => selectedDay.foodItems.dinner,
    };

    if (foodItems.isEmpty) return;

    // Show food selection bottom sheet
    _showFoodSelectionSheet(context, foodItems, selectedDay);
  }

  void _showFoodSelectionSheet(
    BuildContext context,
    List<FoodItem> foodItems,
    dynamic selectedDay,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<OrderFormBloc>(),
        child: FoodSelectionBottomSheet(
          mealType: mealType,
          foodItems: foodItems,
          selectedDay: selectedDay,
        ),
      ),
    );
  }
}
