part of 'notifications_bloc.dart';

@immutable
sealed class NotificationsEvent {}

/// Initialize notifications - fetch initial data
final class NotificationsInitializedEvent extends NotificationsEvent {}

/// Refresh notifications (ignores cache, always fetches)
final class NotificationsRefreshedEvent extends NotificationsEvent {}

/// Smart refresh - only fetches if data is stale (>30 seconds old)
/// Used for automatic refreshes (app resume, tab visibility)
final class NotificationsSmartRefreshedEvent extends NotificationsEvent {}

/// Mark all notifications as read
final class NotificationsMarkAllAsReadEvent extends NotificationsEvent {}

/// Load more notifications (pagination)
final class NotificationsLoadMoreEvent extends NotificationsEvent {}
