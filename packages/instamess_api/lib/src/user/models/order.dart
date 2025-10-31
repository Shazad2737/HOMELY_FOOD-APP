import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/user/models/order_item.dart';

/// Order status enum
enum OrderStatus {
  confirmed,
  delivered,
  cancelled;

  /// Creates OrderStatus from string
  static OrderStatus? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return null;
    }
  }

  /// Convert to display string
  String get displayName {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// {@template order}
/// Represents a customer order
/// {@endtemplate}
class Order extends Equatable {
  /// {@macro order}
  const Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.orderItems,
    this.notes,
  });

  /// Creates Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: pick(json, 'id').asStringOrThrow(),
      orderNumber: pick(json, 'orderNumber').asStringOrThrow(),
      orderDate: pick(json, 'orderDate').asStringOrThrow(),
      status: OrderStatus.fromString(pick(json, 'status').asStringOrNull()) ??
          OrderStatus.confirmed,
      notes: pick(json, 'notes').asStringOrNull(),
      orderItems: pick(json, 'orderItems')
          .asListOrThrow<Map<String, dynamic>>((p0) => p0.asMapOrThrow())
          .map(OrderItem.fromJson)
          .toList(),
    );
  }

  /// Order ID
  final String id;

  /// Order number (e.g., "IOT-000123")
  final String orderNumber;

  /// Order date (yyyy-MM-dd format)
  final String orderDate;

  /// Order status
  final OrderStatus status;

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
      'status': status.name.toUpperCase(),
      'notes': notes,
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [id, orderNumber, orderDate, status, notes, orderItems];
}
