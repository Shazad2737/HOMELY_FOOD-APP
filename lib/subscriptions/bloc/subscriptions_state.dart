part of 'subscriptions_bloc.dart';

@immutable
class SubscriptionsState {
  const SubscriptionsState({
    required this.subscriptionState,
  });

  factory SubscriptionsState.initial() {
    return SubscriptionsState(
      subscriptionState: DataState.initial(),
    );
  }

  final DataState<SubscriptionData> subscriptionState;

  bool get isLoading => subscriptionState.isLoading;
  bool get isRefreshing => subscriptionState.isRefreshing;
  bool get isSuccess => subscriptionState.isSuccess;
  bool get isFailure => subscriptionState.isFailure;

  SubscriptionData? get subscriptionData {
    return subscriptionState.maybeMap(
      success: (DataStateSuccess<SubscriptionData> state) => state.data,
      refreshing: (DataStateRefreshing<SubscriptionData> state) =>
          state.currentData,
      orElse: () => null,
    );
  }

  Failure? get failure {
    return subscriptionState.maybeMap(
      failure: (DataStateFailure<SubscriptionData> state) => state.failure,
      orElse: () => null,
    );
  }

  SubscriptionsState copyWith({
    DataState<SubscriptionData>? subscriptionState,
  }) {
    return SubscriptionsState(
      subscriptionState: subscriptionState ?? this.subscriptionState,
    );
  }

  @override
  String toString() =>
      '''
SubscriptionsState {
  subscriptionState: $subscriptionState
}''';
}
