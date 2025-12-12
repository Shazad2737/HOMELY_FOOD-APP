/// {@template delivery_mode}
/// Mode of delivery for food items
/// {@endtemplate}
enum DeliveryMode {
  /// Delivered separately
  separate,

  /// Delivered with another meal
  withOther;

  /// Parse delivery mode from API string
  static DeliveryMode? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'SEPARATE':
        return DeliveryMode.separate;
      case 'WITH_OTHER':
        return DeliveryMode.withOther;
      default:
        return null;
    }
  }

  /// Convert to API string format
  String toApiString() {
    switch (this) {
      case DeliveryMode.separate:
        return 'SEPARATE';
      case DeliveryMode.withOther:
        return 'WITH_OTHER';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case DeliveryMode.separate:
        return 'Separate Delivery';
      case DeliveryMode.withOther:
        return 'Delivered with Other Meal';
    }
  }
}
