/// {@template meal_type}
/// Type of meal (breakfast, lunch, dinner)
/// {@endtemplate}
enum MealType {
  /// Breakfast meal
  breakfast,

  /// Lunch meal
  lunch,

  /// Dinner meal
  dinner;

  /// Parse meal type from API string
  static MealType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case MealType.breakfast:
        return 'BREAKFAST';
      case MealType.lunch:
        return 'LUNCH';
      case MealType.dinner:
        return 'DINNER';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}
