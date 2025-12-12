import 'package:equatable/equatable.dart';

/// {@template order_item_request}
/// Request for a single order item
/// {@endtemplate}
class OrderItemRequest extends Equatable {
  /// {@macro order_item_request}
  const OrderItemRequest({
    required this.foodItemId,
    required this.mealTypeId,
    required this.deliveryLocationId,
    this.notes,
  });

  /// Food item ID
  final String foodItemId;

  /// Meal type ID
  final String mealTypeId;

  /// Delivery location ID
  final String deliveryLocationId;

  /// Optional notes for this item
  final String? notes;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'foodItemId': foodItemId,
      'mealTypeId': mealTypeId,
      'deliveryLocationId': deliveryLocationId,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props =>
      [foodItemId, mealTypeId, deliveryLocationId, notes];
}

/// {@template create_order_request}
/// Request to create a new order
/// {@endtemplate}
class CreateOrderRequest extends Equatable {
  /// {@macro create_order_request}
  const CreateOrderRequest({
    required this.orderDate,
    required this.orderItems,
    this.notes,
  });

  /// Order date in ISO 8601 format (e.g., "2025-11-05")
  final String orderDate;

  /// Optional notes for the entire order
  final String? notes;

  /// List of order items
  final List<OrderItemRequest> orderItems;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderDate': orderDate,
      if (notes != null) 'notes': notes,
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [orderDate, notes, orderItems];
}
