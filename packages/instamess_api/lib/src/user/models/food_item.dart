import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/user/models/delivery_location.dart';

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
    this.code,
    this.mealTypeId,
    this.isVegetarian,
    this.isVegan,
    this.deliveryMode,
    this.deliverWith,
    this.availableLocations,
    this.price,
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
      code: pick(json, 'code').asStringOrNull(),
      mealTypeId: pick(json, 'mealTypeId').asStringOrNull(),
      isVegetarian: pick(json, 'isVegetarian').asBoolOrNull(),
      isVegan: pick(json, 'isVegan').asBoolOrNull(),
      deliveryMode: pick(json, 'deliveryMode').asStringOrNull(),
      deliverWith: pick(json, 'deliverWith').asStringOrNull(),
      availableLocations: pick(json, 'availableLocations').asListOrNull((pick) {
        return DeliveryLocation.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      price: pick(json, 'price').asDoubleOrNull(),
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

  /// Food item code (e.g., "DS0323")
  final String? code;

  /// Meal type ID reference
  final String? mealTypeId;

  /// Whether the food is vegetarian
  final bool? isVegetarian;

  /// Whether the food is vegan
  final bool? isVegan;

  /// Delivery mode ("SEPARATE" or "WITH_OTHER")
  final String? deliveryMode;

  /// Which meal type this should be delivered with (when deliveryMode is "WITH_OTHER")
  final String? deliverWith;

  /// Available locations for delivery
  final List<DeliveryLocation>? availableLocations;

  /// Price of the food item
  final double? price;

  /// Whether this food has separate delivery
  bool get isSeparateDelivery => deliveryMode == 'SEPARATE';

  /// Whether this food is delivered with another meal
  bool get isGroupedDelivery => deliveryMode == 'WITH_OTHER';

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'style': style,
      'code': code,
      'mealTypeId': mealTypeId,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'deliveryMode': deliveryMode,
      'deliverWith': deliverWith,
      'availableLocations': availableLocations?.map((e) => e.toJson()).toList(),
      'price': price,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        cuisine,
        style,
        code,
        mealTypeId,
        isVegetarian,
        isVegan,
        deliveryMode,
        deliverWith,
        availableLocations,
        price,
      ];
}
