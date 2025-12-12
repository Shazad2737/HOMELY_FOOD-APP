import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription_plan}
/// Represents a subscription plan
/// {@endtemplate}
class SubscriptionPlan extends Equatable {
  /// {@macro subscription_plan}
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Creates SubscriptionPlan from JSON
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      type: pick(json, 'type').asStringOrThrow(),
    );
  }

  /// Plan unique ID
  final String id;

  /// Plan display name (e.g., "Basic", "Premium")
  final String name;

  /// Plan type identifier (e.g., "BASIC", "PREMIUM")
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
