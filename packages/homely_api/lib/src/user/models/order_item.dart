import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/menu/models/food_item.dart';
import 'package:homely_api/src/user/models/delivery_location.dart';
import 'package:homely_api/src/user/models/meal_type.dart';

/// {@template order_item}
/// Represents an item in an order
/// {@endtemplate}
class OrderItem extends Equatable {
  /// {@macro order_item}
  const OrderItem({
    required this.id,
    required this.mealType,
    required this.foodItem,
    this.deliveryLocation,
    this.notes,
  });

  /// Creates OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final deliveryLocationMap =
        pick(json, 'deliveryLocation').asMapOrNull<String, dynamic>();

    return OrderItem(
      id: pick(json, 'id').asStringOrThrow(),
      notes: pick(json, 'notes').asStringOrNull(),
      mealType: MealType.fromJson(
        pick(json, 'mealType').asMapOrThrow<String, dynamic>(),
      ),
      foodItem: FoodItem.fromJson(
        pick(json, 'foodItem').asMapOrThrow<String, dynamic>(),
      ),
      deliveryLocation: deliveryLocationMap != null
          ? DeliveryLocation.fromJson(deliveryLocationMap)
          : null,
    );
  }

  /// Order item ID
  final String id;

  /// Special notes for this item
  final String? notes;

  /// Meal type information
  final MealType mealType;

  /// Food item details
  final FoodItem foodItem;

  /// Delivery location (optional - may not be returned in all responses)
  final DeliveryLocation? deliveryLocation;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': notes,
      'mealType': mealType.toJson(),
      'foodItem': foodItem.toJson(),
      if (deliveryLocation != null)
        'deliveryLocation': deliveryLocation!.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, notes, mealType, foodItem, deliveryLocation];
}
