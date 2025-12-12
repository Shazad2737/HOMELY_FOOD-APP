import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'subscriptions_event.dart';
part 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  SubscriptionsBloc({
    required this.userRepository,
  }) : super(SubscriptionsState.initial()) {
    on<SubscriptionsEvent>((event, emit) async {
      switch (event) {
        case SubscriptionsLoadedEvent():
          await _onLoadedEvent(event, emit);
        case SubscriptionsRefreshedEvent():
          await _onRefreshedEvent(event, emit);
      }
    });
  }

  final IUserRepository userRepository;

  Future<void> _onLoadedEvent(
    SubscriptionsLoadedEvent event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(state.copyWith(subscriptionState: DataState.loading()));

    final result = await userRepository.getSubscription();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            subscriptionState: DataState.failure(failure),
          ),
        );
      },
      (subscriptionData) {
        emit(
          state.copyWith(
            subscriptionState: DataState.success(subscriptionData),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshedEvent(
    SubscriptionsRefreshedEvent event,
    Emitter<SubscriptionsState> emit,
  ) async {
    // Use refreshing state if we already have data
    final currentState = state.subscriptionState;
    if (currentState is DataStateSuccess<SubscriptionData>) {
      emit(
        state.copyWith(
          subscriptionState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(subscriptionState: DataState.loading()));
    }

    final result = await userRepository.getSubscription();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            subscriptionState: DataState.failure(failure),
          ),
        );
      },
      (subscriptionData) {
        emit(
          state.copyWith(
            subscriptionState: DataState.success(subscriptionData),
          ),
        );
      },
    );
  }
}
