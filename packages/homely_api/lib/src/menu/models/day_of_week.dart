/// {@template day_of_week}
/// Day of the week
/// {@endtemplate}
enum DayOfWeek {
  /// Monday
  monday,

  /// Tuesday
  tuesday,

  /// Wednesday
  wednesday,

  /// Thursday
  thursday,

  /// Friday
  friday,

  /// Saturday
  saturday,

  /// Sunday
  sunday;

  /// Parse day of week from API string
  static DayOfWeek? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'MONDAY':
        return DayOfWeek.monday;
      case 'TUESDAY':
        return DayOfWeek.tuesday;
      case 'WEDNESDAY':
        return DayOfWeek.wednesday;
      case 'THURSDAY':
        return DayOfWeek.thursday;
      case 'FRIDAY':
        return DayOfWeek.friday;
      case 'SATURDAY':
        return DayOfWeek.saturday;
      case 'SUNDAY':
        return DayOfWeek.sunday;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case DayOfWeek.monday:
        return 'MONDAY';
      case DayOfWeek.tuesday:
        return 'TUESDAY';
      case DayOfWeek.wednesday:
        return 'WEDNESDAY';
      case DayOfWeek.thursday:
        return 'THURSDAY';
      case DayOfWeek.friday:
        return 'FRIDAY';
      case DayOfWeek.saturday:
        return 'SATURDAY';
      case DayOfWeek.sunday:
        return 'SUNDAY';
    }
  }

  /// Short display name for UI (e.g., MON, TUE)
  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'MON';
      case DayOfWeek.tuesday:
        return 'TUE';
      case DayOfWeek.wednesday:
        return 'WED';
      case DayOfWeek.thursday:
        return 'THU';
      case DayOfWeek.friday:
        return 'FRI';
      case DayOfWeek.saturday:
        return 'SAT';
      case DayOfWeek.sunday:
        return 'SUN';
    }
  }

  /// Full display name for UI
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }
}
