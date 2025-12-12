import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template plan}
/// Plan model for category
/// {@endtemplate}
class Plan extends Equatable {
  /// {@macro plan}
  const Plan({
    this.id,
    this.name,
  });

  /// Creates a Plan from Json map
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: pick(json, 'id').asStringOrNull(),
      name: pick(json, 'name').asStringOrNull(),
    );
  }

  /// Converts Plan to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Plan id
  final String? id;

  /// Plan name
  final String? name;

  @override
  List<Object?> get props => [id, name];
}

/// {@template category}
/// Category model
/// {@endtemplate}
class Category extends Equatable {
  /// {@macro category}
  const Category({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.sortOrder,
    this.plans = const [],
  });

  /// Creates a Category from Json map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: pick(json, 'id').asStringOrNull(),
      name: pick(json, 'name').asStringOrNull(),
      description: pick(json, 'description').asStringOrNull(),
      imageUrl: pick(json, 'imageUrl').asStringOrNull(),
      sortOrder: pick(json, 'sortOrder').asIntOrNull() ?? 0,
      plans: pick(json, 'plans').asListOrEmpty((pick) {
        return Plan.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Converts Category to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'plans': plans.map((e) => e.toJson()).toList(),
    };
  }

  /// Category id
  final String? id;

  /// Category name
  final String? name;

  /// Category description
  final String? description;

  /// Category image URL
  final String? imageUrl;

  /// Sort order
  final int? sortOrder;

  /// Associated plans
  final List<Plan> plans;

  @override
  List<Object?> get props =>
      [id, name, description, imageUrl, sortOrder, plans];
}
