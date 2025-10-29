/// {@template food_style}
/// Style of food preparation
/// {@endtemplate}
enum FoodStyle {
  /// South Indian style
  southIndian,

  /// North Indian style
  northIndian,

  /// Kerala style
  kerala,

  /// Punjabi style
  punjabi,

  /// Bengali style
  bengali,

  /// Gujarati style
  gujarati,

  /// Rajasthani style
  rajasthani,

  /// Fusion style
  fusion,

  /// Other style
  other;

  /// Parse food style from API string
  static FoodStyle? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'SOUTH_INDIAN':
        return FoodStyle.southIndian;
      case 'NORTH_INDIAN':
        return FoodStyle.northIndian;
      case 'KERALA':
        return FoodStyle.kerala;
      case 'PUNJABI':
        return FoodStyle.punjabi;
      case 'BENGALI':
        return FoodStyle.bengali;
      case 'GUJARATI':
        return FoodStyle.gujarati;
      case 'RAJASTHANI':
        return FoodStyle.rajasthani;
      case 'FUSION':
        return FoodStyle.fusion;
      case 'OTHER':
        return FoodStyle.other;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case FoodStyle.southIndian:
        return 'SOUTH_INDIAN';
      case FoodStyle.northIndian:
        return 'NORTH_INDIAN';
      case FoodStyle.kerala:
        return 'KERALA';
      case FoodStyle.punjabi:
        return 'PUNJABI';
      case FoodStyle.bengali:
        return 'BENGALI';
      case FoodStyle.gujarati:
        return 'GUJARATI';
      case FoodStyle.rajasthani:
        return 'RAJASTHANI';
      case FoodStyle.fusion:
        return 'FUSION';
      case FoodStyle.other:
        return 'OTHER';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case FoodStyle.southIndian:
        return 'South Indian';
      case FoodStyle.northIndian:
        return 'North Indian';
      case FoodStyle.kerala:
        return 'Kerala';
      case FoodStyle.punjabi:
        return 'Punjabi';
      case FoodStyle.bengali:
        return 'Bengali';
      case FoodStyle.gujarati:
        return 'Gujarati';
      case FoodStyle.rajasthani:
        return 'Rajasthani';
      case FoodStyle.fusion:
        return 'Fusion';
      case FoodStyle.other:
        return 'Other';
    }
  }
}
