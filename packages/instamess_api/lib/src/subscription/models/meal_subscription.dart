import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template meal_subscription}
/// Represents a meal type subscription status
/// {@endtemplate}
class MealSubscription extends Equatable {
  /// {@macro meal_subscription}
  const MealSubscription({
    required this.id,
    required this.name,
    required this.systemActive,
    required this.customerActive,
    this.startDate,
    this.endDate,
  });

  /// Creates MealSubscription from JSON
  factory MealSubscription.fromJson(Map<String, dynamic> json) {
    return MealSubscription(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      systemActive: pick(json, 'systemActive').asBoolOrThrow(),
      customerActive: pick(json, 'customerActive').asBoolOrThrow(),
      startDate: pick(json, 'startDate').asStringOrNull(),
      endDate: pick(json, 'endDate').asStringOrNull(),
    );
  }

  /// Meal type unique ID
  final String id;

  /// Meal type name (e.g., "Breakfast", "Lunch", "Dinner")
  final String name;

  /// Whether this meal type is available in the system
  final bool systemActive;

  /// Whether customer is subscribed to this meal type
  final bool customerActive;

  /// Subscription start date (YYYY-MM-DD format)
  final String? startDate;

  /// Subscription end date (YYYY-MM-DD format)
  final String? endDate;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemActive': systemActive,
      'customerActive': customerActive,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  /// Returns true if customer has an active subscription
  bool get isSubscribed =>
      customerActive && startDate != null && endDate != null;

  /// Returns true if available for subscription
  bool get isAvailable => systemActive && !customerActive;

  /// Formats date range for display (e.g., "02-December-2025 - 01-January-2026")
  String? get formattedDateRange {
    if (startDate == null || endDate == null) return null;

    try {
      final start = DateTime.parse(startDate!);
      final end = DateTime.parse(endDate!);

      final startFormatted =
          '${start.day.toString().padLeft(2, '0')}-${_monthName(start.month)}-${start.year}';
      final endFormatted =
          '${end.day.toString().padLeft(2, '0')}-${_monthName(end.month)}-${end.year}';

      return '$startFormatted - $endFormatted';
    } catch (_) {
      return null;
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props =>
      [id, name, systemActive, customerActive, startDate, endDate];
}
