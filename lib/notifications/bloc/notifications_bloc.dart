import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
  }) : _notificationRepository = notificationRepository,
       super(NotificationsState.initial()) {
    on<NotificationsInitializedEvent>(_onInitialized);
    on<NotificationsRefreshedEvent>(_onRefreshed);
    // Use restartable + debounce for smart refresh to handle rapid triggers
    // (e.g., quick tab switches, app resume while already loading)
    on<NotificationsSmartRefreshedEvent>(
      _onSmartRefreshed,
      transformer: restartable(),
    );
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
            lastFetchedAt: DateTime.now(),
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
            lastFetchedAt: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> _onSmartRefreshed(
    NotificationsSmartRefreshedEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Check if refresh is needed based on staleness
    if (!state.shouldRefresh()) {
      log('Notifications are fresh, skipping refresh');
      return;
    }

    log('Notifications are stale, refreshing...');

    // Use refreshing state if we have data, otherwise loading
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
        log('Failed to smart refresh notifications: $failure');
        // On failure, keep the old data if available
        if (currentData != null) {
          emit(
            state.copyWith(
              notificationsState: DataState.success(currentData),
            ),
          );
        } else {
          emit(
            state.copyWith(
              notificationsState: DataState.failure(failure),
            ),
          );
        }
      },
      (notificationData) {
        emit(
          state.copyWith(
            notificationsState: DataState.success(notificationData),
            lastFetchedAt: DateTime.now(),
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
