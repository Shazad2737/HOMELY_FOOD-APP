part of 'subscriptions_bloc.dart';

@immutable
sealed class SubscriptionsEvent {}

/// Event to load subscription data
class SubscriptionsLoadedEvent extends SubscriptionsEvent {}

/// Event to refresh subscription data
class SubscriptionsRefreshedEvent extends SubscriptionsEvent {}
