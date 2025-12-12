import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/user/models/order.dart';

/// {@template order_group}
/// Represents a group of orders by date
/// {@endtemplate}
class OrderGroup extends Equatable {
  /// {@macro order_group}
  const OrderGroup({
    required this.date,
    required this.orders,
  });

  /// Creates OrderGroup from JSON
  factory OrderGroup.fromJson(Map<String, dynamic> json) {
    return OrderGroup(
      date: pick(json, 'date').asStringOrThrow(),
      orders: pick(json, 'orders')
          .asListOrThrow<Map<String, dynamic>>((p0) => p0.asMapOrThrow())
          .map(Order.fromJson)
          .toList(),
    );
  }

  /// Date (yyyy-MM-dd format)
  final String date;

  /// List of orders for this date
  final List<Order> orders;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'orders': orders.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [date, orders];
}
