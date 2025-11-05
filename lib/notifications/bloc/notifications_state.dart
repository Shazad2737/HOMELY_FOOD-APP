part of 'notifications_bloc.dart';

@immutable
class NotificationsState {
  const NotificationsState({
    required this.notificationsState,
    this.hasMarkedAllAsRead = false,
  });

  factory NotificationsState.initial() {
    return NotificationsState(
      notificationsState: DataState.initial(),
    );
  }

  final DataState<NotificationData> notificationsState;
  final bool hasMarkedAllAsRead;

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

  Failure? get failure {
    return notificationsState.maybeMap(
      failure: (state) => state.failure,
      orElse: () => null,
    );
  }

  NotificationsState copyWith({
    DataState<NotificationData>? notificationsState,
    bool? hasMarkedAllAsRead,
  }) {
    return NotificationsState(
      notificationsState: notificationsState ?? this.notificationsState,
      hasMarkedAllAsRead: hasMarkedAllAsRead ?? this.hasMarkedAllAsRead,
    );
  }
}
