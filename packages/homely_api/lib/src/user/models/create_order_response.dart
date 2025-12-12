import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/user/models/order_item.dart';

/// {@template create_order_response}
/// Response after creating a new order
/// {@endtemplate}
class CreateOrderResponse extends Equatable {
  /// {@macro create_order_response}
  const CreateOrderResponse({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.orderItems,
    this.notes,
  });

  /// Creates CreateOrderResponse from JSON
  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      id: pick(json, 'id').asStringOrThrow(),
      orderNumber: pick(json, 'orderNumber').asStringOrThrow(),
      orderDate: pick(json, 'orderDate').asStringOrThrow(),
      status: pick(json, 'status').asStringOrThrow(),
      notes: pick(json, 'notes').asStringOrNull(),
      orderItems: pick(json, 'orderItems').asListOrEmpty((pick) {
        return OrderItem.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Order ID
  final String id;

  /// Order number
  final String orderNumber;

  /// Order date
  final String orderDate;

  /// Order status
  final String status;

  /// Order notes
  final String? notes;

  /// List of order items
  final List<OrderItem> orderItems;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate,
      'status': status,
      'notes': notes,
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [id, orderNumber, orderDate, status, notes, orderItems];
}
