import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template unselected_meals_warning_dialog}
/// Dialog that warns users about available meals they haven't selected
/// {@endtemplate}
class UnselectedMealsWarningDialog extends StatelessWidget {
  /// {@macro unselected_meals_warning_dialog}
  const UnselectedMealsWarningDialog({
    required this.unselectedMeals,
    required this.onProceed,
    required this.onCancel,
    super.key,
  });

  /// List of meal types that are available but not selected
  final List<MealType> unselectedMeals;

  /// Callback when user chooses to proceed anyway
  final VoidCallback onProceed;

  /// Callback when user chooses to go back
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warning,
        size: 48,
      ),
      title: const Text('Unselected Meals'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have ${unselectedMeals.length} available meal${unselectedMeals.length == 1 ? '' : 's'} that you haven\'t selected:',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...unselectedMeals.map(
            (mealType) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getMealIcon(mealType),
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMealName(mealType),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can still add these meals to your order if you go back.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Go Back'),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Proceed Anyway'),
        ),
      ],
    );
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.free_breakfast_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
    }
  }

  String _getMealName(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}
