import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template food_item}
/// Represents a food item in an order
/// {@endtemplate}
class FoodItem extends Equatable {
  /// {@macro food_item}
  const FoodItem({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.cuisine,
    this.style,
  });

  /// Creates FoodItem from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      description: pick(json, 'description').asStringOrNull(),
      imageUrl: pick(json, 'imageUrl').asStringOrNull(),
      cuisine: pick(json, 'cuisine').asStringOrNull(),
      style: pick(json, 'style').asStringOrNull(),
    );
  }

  /// Food item ID
  final String id;

  /// Food item name
  final String name;

  /// Food item description
  final String? description;

  /// Food item image URL
  final String? imageUrl;

  /// Cuisine type
  final String? cuisine;

  /// Style
  final String? style;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'style': style,
    };
  }

  @override
  List<Object?> get props => [id, name, description, imageUrl, cuisine, style];
}
