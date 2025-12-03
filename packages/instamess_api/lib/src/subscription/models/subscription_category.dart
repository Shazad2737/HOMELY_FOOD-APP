import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription_category}
/// Represents a subscription category (e.g., cuisine type)
/// {@endtemplate}
class SubscriptionCategory extends Equatable {
  /// {@macro subscription_category}
  const SubscriptionCategory({
    required this.id,
    required this.name,
    this.description,
  });

  /// Creates SubscriptionCategory from JSON
  factory SubscriptionCategory.fromJson(Map<String, dynamic> json) {
    return SubscriptionCategory(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      description: pick(json, 'description').asStringOrNull(),
    );
  }

  /// Category unique ID
  final String id;

  /// Category display name (e.g., "Authentic", "International")
  final String name;

  /// Category description (nullable)
  final String? description;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, description];
}
