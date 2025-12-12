import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

/// Utility class for meal type related operations
class MealTypeHelper {
  const MealTypeHelper._();

  /// Get display label for meal type
  static String getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  /// Get icon for meal type
  static Widget getMealIcon(
    MealType type, {
    required bool isSelected,
    required bool isAvailable,
    double size = 28,
  }) {
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

    return Icon(iconData, color: color, size: size);
  }

  /// Get icon data for meal type (without color)
  static IconData getMealIconData(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }
}
