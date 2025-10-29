import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/plan_type.dart';

/// {@template menu_plan}
/// Represents a subscription plan available in the menu
/// {@endtemplate}
class MenuPlan extends Equatable {
  /// {@macro menu_plan}
  const MenuPlan({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
  });

  /// Parse from JSON
  factory MenuPlan.fromJson(Map<String, dynamic> json) {
    return MenuPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PlanType.fromString(json['type'] as String?) ?? PlanType.basic,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Unique identifier
  final String id;

  /// Plan name (e.g., "Basic", "Premium")
  final String name;

  /// Type of plan
  final PlanType type;

  /// Optional image URL
  final String? imageUrl;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toApiString(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, type, imageUrl];
}
