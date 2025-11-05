import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// {@template notifications_bloc}
/// BLoC to manage notifications state
/// {@endtemplate}
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  /// {@macro notifications_bloc}
  NotificationsBloc({
    required INotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(NotificationsState.initial()) {
    on<NotificationsInitializedEvent>(_onInitialized);
    on<NotificationsRefreshedEvent>(_onRefreshed);
    on<NotificationsMarkAllAsReadEvent>(_onMarkAllAsRead);
    on<NotificationsLoadMoreEvent>(_onLoadMore);
  }

  final INotificationRepository _notificationRepository;

  Future<void> _onInitialized(
    NotificationsInitializedEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(notificationsState: DataState.loading()));

    final result = await _notificationRepository.getNotifications();

    result.fold(
      (failure) {
        log('Failed to load notifications: $failure');
        emit(
          state.copyWith(
            notificationsState: DataState.failure(failure),
          ),
        );
      },
      (notificationData) {
        emit(
          state.copyWith(
            notificationsState: DataState.success(notificationData),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshed(
    NotificationsRefreshedEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // If we have current data, use refreshing state
    final currentData = state.notificationData;
    if (currentData != null) {
      emit(
        state.copyWith(
          notificationsState: DataState.refreshing(currentData),
        ),
      );
    } else {
      emit(state.copyWith(notificationsState: DataState.loading()));
    }

    final result = await _notificationRepository.getNotifications();

    result.fold(
      (failure) {
        log('Failed to refresh notifications: $failure');
        emit(
          state.copyWith(
            notificationsState: DataState.failure(failure),
          ),
        );
      },
      (notificationData) {
        emit(
          state.copyWith(
            notificationsState: DataState.success(notificationData),
          ),
        );
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    NotificationsMarkAllAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) {
        log('Failed to mark all as read: $failure');
        // Optionally show error to user
      },
      (count) {
        log('Marked $count notifications as read');
        emit(state.copyWith(hasMarkedAllAsRead: true));
        // Optionally refresh the notifications list
        add(NotificationsRefreshedEvent());
      },
    );
  }

  Future<void> _onLoadMore(
    NotificationsLoadMoreEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // TODO: Implement pagination if needed
    log('Load more notifications - not implemented yet');
  }
}
