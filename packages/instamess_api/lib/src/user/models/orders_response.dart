import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/user/models/order_group.dart';

/// {@template orders_response}
/// Response from the orders API endpoint
/// {@endtemplate}
class OrdersResponse extends Equatable {
  /// {@macro orders_response}
  const OrdersResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Creates OrdersResponse from JSON
  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      data: pick(json, 'data')
          .asListOrThrow<Map<String, dynamic>>((p0) => p0.asMapOrThrow())
          .map(OrderGroup.fromJson)
          .toList(),
      page: pick(json, 'page').asIntOrThrow(),
      limit: pick(json, 'limit').asIntOrThrow(),
      total: pick(json, 'total').asIntOrThrow(),
      totalPages: pick(json, 'totalPages').asIntOrThrow(),
    );
  }

  /// List of order groups
  final List<OrderGroup> data;

  /// Current page number
  final int page;

  /// Items per page
  final int limit;

  /// Total number of orders
  final int total;

  /// Total number of pages
  final int totalPages;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  @override
  List<Object?> get props => [data, page, limit, total, totalPages];
}
