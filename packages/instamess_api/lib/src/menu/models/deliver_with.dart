import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/meal_type.dart';

/// {@template deliver_with}
/// Information about which meal this item is delivered with
/// {@endtemplate}
class DeliverWith extends Equatable {
  /// {@macro deliver_with}
  const DeliverWith({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Parse from JSON
  factory DeliverWith.fromJson(Map<String, dynamic> json) {
    return DeliverWith(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MealType.fromString(json['type'] as String?) ?? MealType.lunch,
    );
  }

  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Meal type this is delivered with
  final MealType type;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toApiString(),
    };
  }

  @override
  List<Object?> get props => [id, name, type];
}
