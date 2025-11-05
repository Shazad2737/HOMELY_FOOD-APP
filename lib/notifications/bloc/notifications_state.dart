part of 'notifications_bloc.dart';

@immutable
class NotificationsState {
  const NotificationsState({
    required this.notificationsState,
    this.hasMarkedAllAsRead = false,
    this.lastFetchedAt,
  });

  factory NotificationsState.initial() {
    return NotificationsState(
      notificationsState: DataState.initial(),
    );
  }

  final DataState<NotificationData> notificationsState;
  final bool hasMarkedAllAsRead;

  /// Timestamp of the last successful fetch
  /// Used for smart caching to avoid redundant API calls
  final DateTime? lastFetchedAt;

  // Convenience getters
  bool get isLoading => notificationsState.isLoading;
  bool get isRefreshing => notificationsState.isRefreshing;
  bool get isSuccess => notificationsState.isSuccess;
  bool get isFailure => notificationsState.isFailure;

  NotificationData? get notificationData {
    return notificationsState.maybeMap(
      success: (state) => state.data,
      refreshing: (state) => state.currentData,
      orElse: () => null,
    );
  }

  /// Get the count of unread notifications
  int get unreadCount {
    final data = notificationData;
    if (data == null) return 0;

    return data.grouped.all
        .where((notification) => !notification.isRead)
        .length;
  }

  /// Check if there are any unread notifications
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Check if notifications should be refreshed based on last fetch time
  /// Returns true if data is stale (>30 seconds old) or never fetched
  bool shouldRefresh({Duration staleDuration = const Duration(seconds: 30)}) {
    if (lastFetchedAt == null) return true;
    final now = DateTime.now();
    final timeSinceLastFetch = now.difference(lastFetchedAt!);
    return timeSinceLastFetch > staleDuration;
  }

  NotificationsState copyWith({
    DataState<NotificationData>? notificationsState,
    bool? hasMarkedAllAsRead,
    DateTime? lastFetchedAt,
  }) {
    return NotificationsState(
      notificationsState: notificationsState ?? this.notificationsState,
      hasMarkedAllAsRead: hasMarkedAllAsRead ?? this.hasMarkedAllAsRead,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}
