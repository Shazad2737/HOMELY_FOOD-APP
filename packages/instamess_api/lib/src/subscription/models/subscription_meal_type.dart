import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription_meal_type}
/// Represents a subscribed meal type
/// {@endtemplate}
class SubscriptionMealType extends Equatable {
  /// {@macro subscription_meal_type}
  const SubscriptionMealType({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Creates SubscriptionMealType from JSON
  factory SubscriptionMealType.fromJson(Map<String, dynamic> json) {
    return SubscriptionMealType(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      type: pick(json, 'type').asStringOrThrow(),
    );
  }

  /// Meal type unique ID
  final String id;

  /// Meal type display name (e.g., "Breakfast", "Lunch", "Dinner")
  final String name;

  /// Meal type identifier (e.g., "BREAKFAST", "LUNCH", "DINNER")
  final String type;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [id, name, type];
}
