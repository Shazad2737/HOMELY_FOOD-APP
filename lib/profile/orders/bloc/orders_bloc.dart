import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// {@template orders_bloc}
/// BLoC that manages orders state for both ongoing and history orders
/// {@endtemplate}
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  /// {@macro orders_bloc}
  OrdersBloc({
    required this.userRepository,
  }) : super(OrdersState.initial()) {
    on<OrdersEvent>((event, emit) async {
      switch (event) {
        case OrdersOngoingLoadedEvent():
          await _onOngoingLoadedEvent(event, emit);
        case OrdersOngoingLoadMoreEvent():
          await _onOngoingLoadMoreEvent(event, emit);
        case OrdersHistoryLoadedEvent():
          await _onHistoryLoadedEvent(event, emit);
        case OrdersHistoryLoadMoreEvent():
          await _onHistoryLoadMoreEvent(event, emit);
        case OrdersOngoingRefreshedEvent():
          await _onOngoingRefreshedEvent(event, emit);
        case OrdersHistoryRefreshedEvent():
          await _onHistoryRefreshedEvent(event, emit);
      }
    });
  }

  /// User repository
  final IUserRepository userRepository;

  Future<void> _onOngoingLoadedEvent(
    OrdersOngoingLoadedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(ongoingOrdersState: DataState.loading()));

    final result = await userRepository.getOrders(
      type: OrderType.ongoing,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            ongoingOrdersState: DataState.failure(failure),
          ),
        );
      },
      (OrdersResponse response) {
        emit(
          state.copyWith(
            ongoingOrdersState: DataState.success(response),
            ongoingPage: 1,
            ongoingHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onOngoingLoadMoreEvent(
    OrdersOngoingLoadMoreEvent event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't load if already loading or no more items
    if (!state.ongoingHasMore || state.ongoingOrdersState.isLoading) return;

    final currentState = state.ongoingOrdersState;
    if (currentState is! DataStateSuccess<OrdersResponse>) return;

    final nextPage = state.ongoingPage + 1;
    final result = await userRepository.getOrders(
      type: OrderType.ongoing,
      page: nextPage,
    );

    result.fold(
      (Failure failure) {
        // Keep current data on pagination error
      },
      (OrdersResponse response) {
        // Merge with existing data
        final existingData = currentState.data.data;
        final newData = [...existingData, ...response.data];

        final mergedResponse = OrdersResponse(
          data: newData,
          page: response.page,
          limit: response.limit,
          total: response.total,
          totalPages: response.totalPages,
        );

        emit(
          state.copyWith(
            ongoingOrdersState: DataState.success(mergedResponse),
            ongoingPage: nextPage,
            ongoingHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onHistoryLoadedEvent(
    OrdersHistoryLoadedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(historyOrdersState: DataState.loading()));

    final result = await userRepository.getOrders(
      type: OrderType.history,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            historyOrdersState: DataState.failure(failure),
          ),
        );
      },
      (OrdersResponse response) {
        emit(
          state.copyWith(
            historyOrdersState: DataState.success(response),
            historyPage: 1,
            historyHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onHistoryLoadMoreEvent(
    OrdersHistoryLoadMoreEvent event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't load if already loading or no more items
    if (!state.historyHasMore || state.historyOrdersState.isLoading) return;

    final currentState = state.historyOrdersState;
    if (currentState is! DataStateSuccess<OrdersResponse>) return;

    final nextPage = state.historyPage + 1;
    final result = await userRepository.getOrders(
      type: OrderType.history,
      page: nextPage,
    );

    result.fold(
      (Failure failure) {
        // Keep current data on pagination error
      },
      (OrdersResponse response) {
        // Merge with existing data
        final existingData = currentState.data.data;
        final newData = [...existingData, ...response.data];

        final mergedResponse = OrdersResponse(
          data: newData,
          page: response.page,
          limit: response.limit,
          total: response.total,
          totalPages: response.totalPages,
        );

        emit(
          state.copyWith(
            historyOrdersState: DataState.success(mergedResponse),
            historyPage: nextPage,
            historyHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onOngoingRefreshedEvent(
    OrdersOngoingRefreshedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    // Use refreshing state if we already have data
    final currentState = state.ongoingOrdersState;
    if (currentState is DataStateSuccess<OrdersResponse>) {
      emit(
        state.copyWith(
          ongoingOrdersState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(ongoingOrdersState: DataState.loading()));
    }

    final result = await userRepository.getOrders(
      type: OrderType.ongoing,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            ongoingOrdersState: DataState.failure(failure),
          ),
        );
      },
      (OrdersResponse response) {
        emit(
          state.copyWith(
            ongoingOrdersState: DataState.success(response),
            ongoingPage: 1,
            ongoingHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onHistoryRefreshedEvent(
    OrdersHistoryRefreshedEvent event,
    Emitter<OrdersState> emit,
  ) async {
    // Use refreshing state if we already have data
    final currentState = state.historyOrdersState;
    if (currentState is DataStateSuccess<OrdersResponse>) {
      emit(
        state.copyWith(
          historyOrdersState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(historyOrdersState: DataState.loading()));
    }

    final result = await userRepository.getOrders(
      type: OrderType.history,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            historyOrdersState: DataState.failure(failure),
          ),
        );
      },
      (OrdersResponse response) {
        emit(
          state.copyWith(
            historyOrdersState: DataState.success(response),
            historyPage: 1,
            historyHasMore: response.page < response.totalPages,
          ),
        );
      },
    );
  }
}
