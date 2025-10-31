part of 'orders_bloc.dart';

/// Base event for orders
sealed class OrdersEvent {
  const OrdersEvent();
}

/// Event to load ongoing orders
final class OrdersOngoingLoadedEvent extends OrdersEvent {
  const OrdersOngoingLoadedEvent();
}

/// Event to load more ongoing orders (pagination)
final class OrdersOngoingLoadMoreEvent extends OrdersEvent {
  const OrdersOngoingLoadMoreEvent();
}

/// Event to load history orders
final class OrdersHistoryLoadedEvent extends OrdersEvent {
  const OrdersHistoryLoadedEvent();
}

/// Event to load more history orders (pagination)
final class OrdersHistoryLoadMoreEvent extends OrdersEvent {
  const OrdersHistoryLoadMoreEvent();
}

/// Event to refresh ongoing orders
final class OrdersOngoingRefreshedEvent extends OrdersEvent {
  const OrdersOngoingRefreshedEvent();
}

/// Event to refresh history orders
final class OrdersHistoryRefreshedEvent extends OrdersEvent {
  const OrdersHistoryRefreshedEvent();
}
