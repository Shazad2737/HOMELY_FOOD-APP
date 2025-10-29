/// {@template cuisine}
/// Type of cuisine
/// {@endtemplate}
enum Cuisine {
  /// South Indian cuisine
  southIndian,

  /// North Indian cuisine
  northIndian,

  /// Kerala cuisine
  kerala,

  /// Chinese cuisine
  chinese,

  /// Continental cuisine
  continental,

  /// Italian cuisine
  italian,

  /// Mexican cuisine
  mexican,

  /// Other cuisine
  other;

  /// Parse cuisine from API string
  static Cuisine? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'SOUTH_INDIAN':
        return Cuisine.southIndian;
      case 'NORTH_INDIAN':
        return Cuisine.northIndian;
      case 'KERALA':
        return Cuisine.kerala;
      case 'CHINESE':
        return Cuisine.chinese;
      case 'CONTINENTAL':
        return Cuisine.continental;
      case 'ITALIAN':
        return Cuisine.italian;
      case 'MEXICAN':
        return Cuisine.mexican;
      case 'OTHER':
        return Cuisine.other;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case Cuisine.southIndian:
        return 'SOUTH_INDIAN';
      case Cuisine.northIndian:
        return 'NORTH_INDIAN';
      case Cuisine.kerala:
        return 'KERALA';
      case Cuisine.chinese:
        return 'CHINESE';
      case Cuisine.continental:
        return 'CONTINENTAL';
      case Cuisine.italian:
        return 'ITALIAN';
      case Cuisine.mexican:
        return 'MEXICAN';
      case Cuisine.other:
        return 'OTHER';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case Cuisine.southIndian:
        return 'South Indian';
      case Cuisine.northIndian:
        return 'North Indian';
      case Cuisine.kerala:
        return 'Kerala';
      case Cuisine.chinese:
        return 'Chinese';
      case Cuisine.continental:
        return 'Continental';
      case Cuisine.italian:
        return 'Italian';
      case Cuisine.mexican:
        return 'Mexican';
      case Cuisine.other:
        return 'Other';
    }
  }
}
