import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription}
/// Represents a subscription with its details
/// {@endtemplate}
class Subscription extends Equatable {
  /// {@macro subscription}
  const Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.subscribedMealTypes,
    this.categoryName,
    this.planName,
  });

  /// Creates Subscription from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: pick(json, 'id').asStringOrThrow(),
      startDate: pick(json, 'startDate').asStringOrThrow(),
      endDate: pick(json, 'endDate').asStringOrThrow(),
      subscribedMealTypes: pick(json, 'subscribedMealTypes')
          .asListOrEmpty((pick) => pick.asStringOrThrow()),
      categoryName: pick(json, 'category', 'name').asStringOrNull(),
      planName: pick(json, 'plan', 'name').asStringOrNull(),
    );
  }

  /// Subscription ID
  final String id;

  /// Category name (nullable)
  final String? categoryName;

  /// Plan name (nullable)
  final String? planName;

  /// Start date (ISO 8601 format)
  final String startDate;

  /// End date (ISO 8601 format)
  final String endDate;

  /// List of subscribed meal types (e.g., ["BREAKFAST", "LUNCH"])
  final List<String> subscribedMealTypes;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'subscribedMealTypes': subscribedMealTypes,
      if (categoryName != null) 'category': {'name': categoryName},
      if (planName != null) 'plan': {'name': planName},
    };
  }

  @override
  List<Object?> get props =>
      [id, categoryName, planName, startDate, endDate, subscribedMealTypes];
}
