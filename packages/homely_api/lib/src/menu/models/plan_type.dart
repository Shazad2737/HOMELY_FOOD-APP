/// {@template plan_type}
/// Type of subscription plan
/// {@endtemplate}
enum PlanType {
  /// Basic plan
  basic,

  /// Premium plan
  premium,

  /// Ultimate plan
  ultimate;

  /// Parse plan type from API string
  static PlanType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'BASIC':
        return PlanType.basic;
      case 'PREMIUM':
        return PlanType.premium;
      case 'ULTIMATE':
        return PlanType.ultimate;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case PlanType.basic:
        return 'BASIC';
      case PlanType.premium:
        return 'PREMIUM';
      case PlanType.ultimate:
        return 'ULTIMATE';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PlanType.basic:
        return 'Basic';
      case PlanType.premium:
        return 'Premium';
      case PlanType.ultimate:
        return 'Ultimate';
    }
  }
}
