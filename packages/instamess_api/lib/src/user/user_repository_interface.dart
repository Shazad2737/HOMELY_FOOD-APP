import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart'
    as subscription_models;
import 'package:instamess_api/src/user/models/models.dart';

/// Order type for filtering
enum OrderType {
  /// Ongoing orders (CONFIRMED status)
  ongoing,

  /// History orders (DELIVERED or CANCELLED status)
  history;

  /// Convert to API query parameter value
  String toQueryParam() {
    switch (this) {
      case OrderType.ongoing:
        return 'ongoing';
      case OrderType.history:
        return 'history';
    }
  }
}

/// {@template user_repository_interface}
/// Interface for user-related operations (orders, subscriptions, profile)
/// {@endtemplate}
abstract class IUserRepository {
  /// Get orders with pagination
  ///
  /// [type] - Type of orders to fetch (ongoing or history)
  /// [page] - Page number (default 1)
  /// [limit] - Items per page (default 10)
  Future<Either<Failure, OrdersResponse>> getOrders({
    required OrderType type,
    int page = 1,
    int limit = 10,
  });

  /// Get user's subscription data including meal types, banner, and contact info
  Future<Either<Failure, subscription_models.SubscriptionData>>
      getSubscription();

  /// Get available order days with food items and ordering rules
  Future<Either<Failure, AvailableOrderDays>> getAvailableOrderDays();

  /// Create a new order
  Future<Either<Failure, CreateOrderResponse>> createOrder(
    CreateOrderRequest request,
  );
}
