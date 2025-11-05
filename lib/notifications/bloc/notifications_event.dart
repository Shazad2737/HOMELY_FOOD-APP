part of 'notifications_bloc.dart';

@immutable
sealed class NotificationsEvent {}

/// Initialize notifications - fetch initial data
final class NotificationsInitializedEvent extends NotificationsEvent {}

/// Refresh notifications
final class NotificationsRefreshedEvent extends NotificationsEvent {}

/// Mark all notifications as read
final class NotificationsMarkAllAsReadEvent extends NotificationsEvent {}

/// Load more notifications (pagination)
final class NotificationsLoadMoreEvent extends NotificationsEvent {}
