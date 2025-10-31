part of 'orders_bloc.dart';

/// {@template orders_state}
/// State for orders screen
/// {@endtemplate}
class OrdersState extends Equatable {
  /// {@macro orders_state}
  const OrdersState({
    required this.ongoingOrdersState,
    required this.historyOrdersState,
    this.ongoingPage = 1,
    this.historyPage = 1,
    this.ongoingHasMore = true,
    this.historyHasMore = true,
  });

  /// Initial state
  factory OrdersState.initial() {
    return OrdersState(
      ongoingOrdersState: DataState.initial(),
      historyOrdersState: DataState.initial(),
    );
  }

  /// Data state for ongoing orders
  final DataState<OrdersResponse> ongoingOrdersState;

  /// Data state for history orders
  final DataState<OrdersResponse> historyOrdersState;

  /// Current page for ongoing orders
  final int ongoingPage;

  /// Current page for history orders
  final int historyPage;

  /// Whether there are more ongoing orders to load
  final bool ongoingHasMore;

  /// Whether there are more history orders to load
  final bool historyHasMore;

  /// Copy with method
  OrdersState copyWith({
    DataState<OrdersResponse>? ongoingOrdersState,
    DataState<OrdersResponse>? historyOrdersState,
    int? ongoingPage,
    int? historyPage,
    bool? ongoingHasMore,
    bool? historyHasMore,
  }) {
    return OrdersState(
      ongoingOrdersState: ongoingOrdersState ?? this.ongoingOrdersState,
      historyOrdersState: historyOrdersState ?? this.historyOrdersState,
      ongoingPage: ongoingPage ?? this.ongoingPage,
      historyPage: historyPage ?? this.historyPage,
      ongoingHasMore: ongoingHasMore ?? this.ongoingHasMore,
      historyHasMore: historyHasMore ?? this.historyHasMore,
    );
  }

  @override
  List<Object?> get props => [
    ongoingOrdersState,
    historyOrdersState,
    ongoingPage,
    historyPage,
    ongoingHasMore,
    historyHasMore,
  ];
}
