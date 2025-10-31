# Notifications Feature Implementation Plan

## Overview
Complete implementation plan for a notifications screen following the app's architecture patterns (BLoC + DataState + fpdart + modular packages).

**Backend API Base URL:** `/api/notifications`

---

## 📱 Design Reference

Based on the provided design:
- **Clean list layout** with grouped sections (Today, Yesterday, This Week, This Month, Older)
- **Notification items** with:
  - Left: Circular avatar/icon (image or icon with colored background)
  - Middle: Caption (bold) + Description (gray text)
  - Right: Time ago + optional blue dot badge for unread
- **Section headers**: Simple text labels
- **White background** with subtle dividers
- **Read state**: Blue dot indicator on right side for unread items
- **Navigation**: Back button + "Mark all as read" action in app bar

---

## 🎯 Key Requirements

1. ✅ **No filters** - Show all notifications in one view
2. ✅ **Follow promo banner patterns** - Similar navigation handling for actionUrl
3. ✅ **Bulk mark-as-read only** - Triggered by app bar action button
4. ✅ **Infinite scroll** - Auto-load more when reaching bottom
5. ✅ **Real-time updates**: 
   - Auto-refresh on app foreground
   - Auto-refresh when navigating to notifications screen
   - Pull-to-refresh available
   - Background polling (30-second interval)
6. ✅ **Design-based icons**: Circular avatars with images or colored icon backgrounds
7. ✅ **Immediate badge update**: After mark-all-as-read, update HomeBloc state immediately (optimistic update)
8. ✅ **Empty state**: Nice illustration with encouraging message

---

## 🏗️ Architecture Implementation

### **Phase 1: API Layer (`packages/instamess_api/`)**

#### **Directory Structure**
```
packages/instamess_api/lib/src/notifications/
  ├── models/
  │   ├── notification.dart
  │   ├── notification_pagination.dart
  │   ├── grouped_notifications.dart
  │   ├── notifications_response.dart
  │   └── models.dart
  ├── notifications_facade_interface.dart
  ├── notifications_repository.dart
  └── notifications.dart
```

#### **A. Models** (`lib/src/notifications/models/`)

**1. `notification.dart`**
```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template notification}
/// Notification model
/// {@endtemplate}
class Notification extends Equatable {
  /// {@macro notification}
  const Notification({
    required this.id,
    required this.caption,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.priority,
    this.actionUrl,
    required this.sentAt,
    required this.timeAgo,
    required this.dayCategory,
    required this.isRead,
    this.readAt,
  });

  /// Creates a Notification from Json map
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: pick(json, 'id').asStringOrThrow(),
      caption: pick(json, 'caption').asStringOrThrow(),
      description: pick(json, 'description').asStringOrThrow(),
      imageUrl: pick(json, 'imageUrl').asStringOrNull(),
      type: pick(json, 'type').asStringOrThrow(),
      priority: pick(json, 'priority').asStringOrThrow(),
      actionUrl: pick(json, 'actionUrl').asStringOrNull(),
      sentAt: pick(json, 'sentAt').asStringOrThrow(),
      timeAgo: pick(json, 'timeAgo').asStringOrThrow(),
      dayCategory: pick(json, 'dayCategory').asStringOrThrow(),
      isRead: pick(json, 'isRead').asBoolOrThrow(),
      readAt: pick(json, 'readAt').asStringOrNull(),
    );
  }

  /// Converts Notification to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'priority': priority,
      'actionUrl': actionUrl,
      'sentAt': sentAt,
      'timeAgo': timeAgo,
      'dayCategory': dayCategory,
      'isRead': isRead,
      'readAt': readAt,
    };
  }

  /// Unique notification ID
  final String id;

  /// Notification title/caption
  final String caption;

  /// Notification description/body
  final String description;

  /// Optional image URL
  final String? imageUrl;

  /// Notification type (order, promo, reminder, etc.)
  final String type;

  /// Notification priority (high, medium, low)
  final String priority;

  /// Optional action URL for navigation
  final String? actionUrl;

  /// Sent timestamp (formatted datetime from backend)
  final String sentAt;

  /// Human-readable time ago (e.g., "2 hours ago")
  final String timeAgo;

  /// Day category for grouping (today, yesterday, this_week, this_month, older)
  final String dayCategory;

  /// Whether notification has been read
  final bool isRead;

  /// Read timestamp (formatted datetime from backend)
  final String? readAt;

  /// Creates a copy with updated read status
  Notification copyWithRead() {
    return Notification(
      id: id,
      caption: caption,
      description: description,
      imageUrl: imageUrl,
      type: type,
      priority: priority,
      actionUrl: actionUrl,
      sentAt: sentAt,
      timeAgo: timeAgo,
      dayCategory: dayCategory,
      isRead: true,
      readAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        caption,
        description,
        imageUrl,
        type,
        priority,
        actionUrl,
        sentAt,
        timeAgo,
        dayCategory,
        isRead,
        readAt,
      ];
}
```

**2. `notification_pagination.dart`**
```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template notification_pagination}
/// Pagination metadata for notifications
/// {@endtemplate}
class NotificationPagination extends Equatable {
  /// {@macro notification_pagination}
  const NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Creates a NotificationPagination from Json map
  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      page: pick(json, 'page').asIntOrThrow(),
      limit: pick(json, 'limit').asIntOrThrow(),
      total: pick(json, 'total').asIntOrThrow(),
      totalPages: pick(json, 'totalPages').asIntOrThrow(),
    );
  }

  /// Converts NotificationPagination to Json map
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  /// Current page number
  final int page;

  /// Items per page
  final int limit;

  /// Total number of notifications
  final int total;

  /// Total number of pages
  final int totalPages;

  /// Whether there are more pages to load
  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}
```

**3. `grouped_notifications.dart`**
```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/notifications/models/notification.dart';

/// {@template grouped_notifications}
/// Notifications grouped by time period
/// {@endtemplate}
class GroupedNotifications extends Equatable {
  /// {@macro grouped_notifications}
  const GroupedNotifications({
    this.today = const [],
    this.yesterday = const [],
    this.thisWeek = const [],
    this.thisMonth = const [],
    this.older = const [],
  });

  /// Creates a GroupedNotifications from Json map
  factory GroupedNotifications.fromJson(Map<String, dynamic> json) {
    return GroupedNotifications(
      today: pick(json, 'today').asListOrEmpty((pick) {
        return Notification.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      yesterday: pick(json, 'yesterday').asListOrEmpty((pick) {
        return Notification.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      thisWeek: pick(json, 'this_week').asListOrEmpty((pick) {
        return Notification.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      thisMonth: pick(json, 'this_month').asListOrEmpty((pick) {
        return Notification.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      older: pick(json, 'older').asListOrEmpty((pick) {
        return Notification.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Converts GroupedNotifications to Json map
  Map<String, dynamic> toJson() {
    return {
      'today': today.map((e) => e.toJson()).toList(),
      'yesterday': yesterday.map((e) => e.toJson()).toList(),
      'this_week': thisWeek.map((e) => e.toJson()).toList(),
      'this_month': thisMonth.map((e) => e.toJson()).toList(),
      'older': older.map((e) => e.toJson()).toList(),
    };
  }

  /// Notifications from today
  final List<Notification> today;

  /// Notifications from yesterday
  final List<Notification> yesterday;

  /// Notifications from this week
  final List<Notification> thisWeek;

  /// Notifications from this month
  final List<Notification> thisMonth;

  /// Older notifications
  final List<Notification> older;

  /// Get all notifications as a flattened list
  List<Notification> getAllNotifications() {
    return [
      ...today,
      ...yesterday,
      ...thisWeek,
      ...thisMonth,
      ...older,
    ];
  }

  /// Get total count of all notifications
  int getTotalCount() {
    return today.length +
        yesterday.length +
        thisWeek.length +
        thisMonth.length +
        older.length;
  }

  /// Get count of unread notifications
  int getUnreadCount() {
    return getAllNotifications().where((n) => !n.isRead).length;
  }

  /// Whether there are any unread notifications
  bool get hasUnread => getUnreadCount() > 0;

  /// Mark all notifications as read
  GroupedNotifications markAllAsRead() {
    return GroupedNotifications(
      today: today.map((n) => n.copyWithRead()).toList(),
      yesterday: yesterday.map((n) => n.copyWithRead()).toList(),
      thisWeek: thisWeek.map((n) => n.copyWithRead()).toList(),
      thisMonth: thisMonth.map((n) => n.copyWithRead()).toList(),
      older: older.map((n) => n.copyWithRead()).toList(),
    );
  }

  /// Merge with another GroupedNotifications (for pagination)
  GroupedNotifications mergeWith(GroupedNotifications other) {
    return GroupedNotifications(
      today: [...today, ...other.today],
      yesterday: [...yesterday, ...other.yesterday],
      thisWeek: [...thisWeek, ...other.thisWeek],
      thisMonth: [...thisMonth, ...other.thisMonth],
      older: [...older, ...other.older],
    );
  }

  @override
  List<Object?> get props => [today, yesterday, thisWeek, thisMonth, older];
}
```

**4. `notifications_response.dart`**
```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/notifications/models/grouped_notifications.dart';
import 'package:instamess_api/src/notifications/models/notification_pagination.dart';

/// {@template notifications_response}
/// Response from notifications API
/// {@endtemplate}
class NotificationsResponse extends Equatable {
  /// {@macro notifications_response}
  const NotificationsResponse({
    required this.grouped,
    required this.pagination,
  });

  /// Creates a NotificationsResponse from Json map
  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      grouped: GroupedNotifications.fromJson(
        pick(json, 'grouped').asMapOrThrow<String, dynamic>(),
      ),
      pagination: NotificationPagination.fromJson(
        pick(json, 'pagination').asMapOrThrow<String, dynamic>(),
      ),
    );
  }

  /// Converts NotificationsResponse to Json map
  Map<String, dynamic> toJson() {
    return {
      'grouped': grouped.toJson(),
      'pagination': pagination.toJson(),
    };
  }

  /// Grouped notifications by time period
  final GroupedNotifications grouped;

  /// Pagination metadata
  final NotificationPagination pagination;

  /// Whether there are more pages to load
  bool get hasMore => pagination.hasMore;

  /// Merge with another response (for pagination)
  NotificationsResponse mergeWith(NotificationsResponse other) {
    return NotificationsResponse(
      grouped: grouped.mergeWith(other.grouped),
      pagination: other.pagination, // Use latest pagination
    );
  }

  /// Mark all notifications as read
  NotificationsResponse markAllAsRead() {
    return NotificationsResponse(
      grouped: grouped.markAllAsRead(),
      pagination: pagination,
    );
  }

  @override
  List<Object?> get props => [grouped, pagination];
}
```

**5. `models.dart`** (Barrel export)
```dart
export 'grouped_notifications.dart';
export 'notification.dart';
export 'notification_pagination.dart';
export 'notifications_response.dart';
```

---

#### **B. Repository Interface** (`notifications_facade_interface.dart`)

```dart
import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/notifications/models/models.dart';

/// {@template notifications_facade_interface}
/// Interface for notifications operations
/// {@endtemplate}
abstract class INotificationsRepository {
  /// Fetch notifications with pagination
  ///
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  /// Mark all notifications as read
  ///
  /// Returns the count of notifications marked as read
  Future<Either<Failure, int>> markAllAsRead();
}
```

---

#### **C. Repository Implementation** (`notifications_repository.dart`)

```dart
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/notifications/models/models.dart';
import 'package:instamess_api/src/notifications/notifications_facade_interface.dart';

/// {@template notifications_repository}
/// Notifications repository implementation
///
/// This class is responsible for handling all notification-related tasks
/// such as fetching notifications and marking them as read.
/// {@endtemplate}
class NotificationsRepository implements INotificationsRepository {
  /// {@macro notifications_repository}
  NotificationsRepository({
    required this.apiClient,
  });

  /// Api client
  final ApiClient apiClient;

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      authRequired: true,
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching notifications: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'No response body while fetching notifications',
            ),
          );
        }

        final success = body['success'] as bool? ?? false;
        if (!success) {
          final message = body['message'] as String? ?? 'Failed to fetch notifications';
          log('Error fetching notifications: $message');
          return left(
            UnknownApiFailure(
              response.statusCode ?? 0,
              message,
            ),
          );
        }

        try {
          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            return left(
              const UnknownApiFailure(
                0,
                'No data in response while fetching notifications',
              ),
            );
          }

          final notificationsResponse = NotificationsResponse.fromJson(data);
          return right(notificationsResponse);
        } catch (e, stackTrace) {
          log(
            'Error parsing notifications response',
            error: e,
            stackTrace: stackTrace,
          );
          return left(
            UnknownApiFailure(
              response.statusCode ?? 0,
              'Failed to parse notifications: ${e.toString()}',
            ),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, int>> markAllAsRead() async {
    final resEither = await apiClient.post<Map<String, dynamic>>(
      'notifications/read-all',
      authRequired: true,
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error marking notifications as read: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'No response body while marking notifications as read',
            ),
          );
        }

        final success = body['success'] as bool? ?? false;
        if (!success) {
          final message = body['message'] as String? ?? 'Failed to mark notifications as read';
          log('Error marking notifications as read: $message');
          return left(
            UnknownApiFailure(
              response.statusCode ?? 0,
              message,
            ),
          );
        }

        try {
          final data = body['data'] as Map<String, dynamic>?;
          final count = data?['count'] as int? ?? 0;
          return right(count);
        } catch (e, stackTrace) {
          log(
            'Error parsing mark-all-as-read response',
            error: e,
            stackTrace: stackTrace,
          );
          return left(
            UnknownApiFailure(
              response.statusCode ?? 0,
              'Failed to parse response: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}
```

---

#### **D. Barrel Export** (`notifications.dart`)

```dart
export 'models/models.dart';
export 'notifications_facade_interface.dart';
export 'notifications_repository.dart';
```

---

#### **E. Integration into InstaMessApi**

**Update `packages/instamess_api/lib/src/instamess_api.dart`:**

```dart
// Add import
import 'package:instamess_api/src/notifications/notifications.dart';

abstract class IInstaMessApi {
  // ... existing getters
  
  /// Notifications Facade
  INotificationsRepository get notificationsFacade;
}

class InstaMessApi implements IInstaMessApi {
  // ... existing code
  
  late final INotificationsRepository _notificationsFacade;
  
  InstaMessApi({required String baseUrl}) : _storageController = SecureStorageController.instance() {
    // ... existing initialization
    
    // Create notifications facade
    _notificationsFacade = NotificationsRepository(
      apiClient: _apiClient,
    );
  }
  
  @override
  INotificationsRepository get notificationsFacade => _notificationsFacade;
}
```

**Update `packages/instamess_api/lib/instamess_api.dart`** (main barrel export):

```dart
// Add export
export 'src/notifications/notifications.dart';
```

---

### **Phase 2: Feature Layer (`lib/notifications/`)**

#### **Directory Structure**
```
lib/notifications/
  ├── bloc/
  │   ├── notification_bloc.dart
  │   ├── notification_event.dart
  │   └── notification_state.dart
  └── view/
      ├── notifications_screen.dart
      └── widgets/
          ├── notification_list.dart
          ├── notification_item.dart
          ├── empty_notifications_state.dart
          └── notification_loading_shimmer.dart
```

---

#### **A. BLoC** (`lib/notifications/bloc/`)

**1. `notification_event.dart`**
```dart
part of 'notification_bloc.dart';

/// Base notification event
sealed class NotificationEvent {}

/// Load notifications (initial load)
final class NotificationsLoadedEvent extends NotificationEvent {}

/// Refresh notifications (pull-to-refresh)
final class NotificationsRefreshedEvent extends NotificationEvent {}

/// Load more notifications (pagination)
final class NotificationsLoadMoreEvent extends NotificationEvent {}

/// Mark all notifications as read
final class NotificationMarkAllAsReadEvent extends NotificationEvent {}
```

**2. `notification_state.dart`**
```dart
part of 'notification_bloc.dart';

@immutable
class NotificationState {
  const NotificationState({
    required this.notificationsState,
    required this.markAllAsReadState,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  factory NotificationState.initial() {
    return NotificationState(
      notificationsState: DataState.initial(),
      markAllAsReadState: DataState.initial(),
    );
  }

  final DataState<NotificationsResponse> notificationsState;
  final DataState<int> markAllAsReadState;
  final int currentPage;
  final bool isLoadingMore;

  // Convenience getters
  bool get isLoading => notificationsState.isLoading;
  bool get isRefreshing => notificationsState.isRefreshing;
  bool get isSuccess => notificationsState.isSuccess;
  bool get isFailure => notificationsState.isFailure;

  NotificationsResponse? get notificationsData {
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

  bool get hasMore {
    final data = notificationsData;
    if (data == null) return false;
    return data.hasMore;
  }

  bool get canMarkAsRead {
    final data = notificationsData;
    if (data == null) return false;
    return data.grouped.hasUnread;
  }

  NotificationState copyWith({
    DataState<NotificationsResponse>? notificationsState,
    DataState<int>? markAllAsReadState,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return NotificationState(
      notificationsState: notificationsState ?? this.notificationsState,
      markAllAsReadState: markAllAsReadState ?? this.markAllAsReadState,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  String toString() => '''
NotificationState {
  notificationsState: $notificationsState,
  markAllAsReadState: $markAllAsReadState,
  currentPage: $currentPage,
  isLoadingMore: $isLoadingMore
}
''';
}
```

**3. `notification_bloc.dart`**
```dart
import 'dart:async';
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/bloc/home_bloc.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required INotificationsRepository notificationsRepository,
    required HomeBloc homeBloc,
  })  : _notificationsRepository = notificationsRepository,
        _homeBloc = homeBloc,
        super(NotificationState.initial()) {
    on<NotificationEvent>((event, emit) async {
      switch (event) {
        case NotificationsLoadedEvent():
          await _onLoadedEvent(event, emit);
        case NotificationsRefreshedEvent():
          await _onRefreshedEvent(event, emit);
        case NotificationsLoadMoreEvent():
          await _onLoadMoreEvent(event, emit);
        case NotificationMarkAllAsReadEvent():
          await _onMarkAllAsReadEvent(event, emit);
      }
    });

    // Start background polling
    _startPolling();
  }

  final INotificationsRepository _notificationsRepository;
  final HomeBloc _homeBloc;
  Timer? _pollingTimer;

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(NotificationsRefreshedEvent());
    });
  }

  Future<void> _onLoadedEvent(
    NotificationsLoadedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(
      notificationsState: DataState.loading(),
      currentPage: 1,
    ));

    final result = await _notificationsRepository.getNotifications(
      page: 1,
      limit: 20,
    );

    result.fold(
      (failure) {
        log('Error loading notifications: ${failure.message}');
        emit(state.copyWith(
          notificationsState: DataState.failure(failure),
        ));
      },
      (response) {
        emit(state.copyWith(
          notificationsState: DataState.success(response),
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onRefreshedEvent(
    NotificationsRefreshedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentData = state.notificationsData;

    // If we have data, use refreshing state; otherwise use loading
    if (currentData != null) {
      emit(state.copyWith(
        notificationsState: DataState.refreshing(currentData),
        currentPage: 1,
      ));
    } else {
      emit(state.copyWith(
        notificationsState: DataState.loading(),
        currentPage: 1,
      ));
    }

    final result = await _notificationsRepository.getNotifications(
      page: 1,
      limit: 20,
    );

    result.fold(
      (failure) {
        log('Error refreshing notifications: ${failure.message}');
        // Keep current data on failure if refreshing
        if (currentData != null) {
          emit(state.copyWith(
            notificationsState: DataState.success(currentData),
          ));
        } else {
          emit(state.copyWith(
            notificationsState: DataState.failure(failure),
          ));
        }
      },
      (response) {
        emit(state.copyWith(
          notificationsState: DataState.success(response),
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onLoadMoreEvent(
    NotificationsLoadMoreEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Don't load if already loading more or no more pages
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _notificationsRepository.getNotifications(
      page: nextPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        log('Error loading more notifications: ${failure.message}');
        emit(state.copyWith(isLoadingMore: false));
      },
      (response) {
        final currentData = state.notificationsData;
        if (currentData != null) {
          // Merge new data with existing data
          final mergedResponse = currentData.mergeWith(response);
          emit(state.copyWith(
            notificationsState: DataState.success(mergedResponse),
            currentPage: nextPage,
            isLoadingMore: false,
          ));
        } else {
          // Shouldn't happen, but handle gracefully
          emit(state.copyWith(
            notificationsState: DataState.success(response),
            currentPage: nextPage,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onMarkAllAsReadEvent(
    NotificationMarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(
      markAllAsReadState: DataState.loading(),
    ));

    // Optimistically update home badge immediately
    _homeBloc.add(
      const HomeNotificationBadgeUpdatedEvent(
        unreadCount: 0,
        hasUnread: false,
      ),
    );

    final result = await _notificationsRepository.markAllAsRead();

    result.fold(
      (failure) {
        log('Error marking notifications as read: ${failure.message}');
        // API failed - trigger home refresh to restore accurate state
        _homeBloc.add(HomeRefreshedEvent());

        emit(state.copyWith(
          markAllAsReadState: DataState.failure(failure),
        ));
      },
      (count) {
        log('Successfully marked $count notifications as read');

        // Update local notifications state to reflect read status
        final currentData = state.notificationsData;
        if (currentData != null) {
          final updatedResponse = currentData.markAllAsRead();
          emit(state.copyWith(
            notificationsState: DataState.success(updatedResponse),
            markAllAsReadState: DataState.success(count),
          ));
        } else {
          emit(state.copyWith(
            markAllAsReadState: DataState.success(count),
          ));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
```

---

#### **B. View** (`lib/notifications/view/`)

**1. `notifications_screen.dart`**
```dart
import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/bloc/home_bloc.dart';
import 'package:instamess_app/notifications/bloc/notification_bloc.dart';
import 'package:instamess_app/notifications/view/widgets/empty_notifications_state.dart';
import 'package:instamess_app/notifications/view/widgets/notification_list.dart';
import 'package:instamess_app/notifications/view/widgets/notification_loading_shimmer.dart';
import 'package:instamess_app/router/utils/banner_navigation_handler.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(
        notificationsRepository: context.read<INotificationsRepository>(),
        homeBloc: context.read<HomeBloc>(),
      )..add(NotificationsLoadedEvent()),
      child: const _NotificationsScreenContent(),
    );
  }
}

class _NotificationsScreenContent extends StatefulWidget {
  const _NotificationsScreenContent();

  @override
  State<_NotificationsScreenContent> createState() =>
      _NotificationsScreenContentState();
}

class _NotificationsScreenContentState
    extends State<_NotificationsScreenContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Trigger home refresh when leaving notifications screen
    context.read<HomeBloc>().add(HomeRefreshedEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh notifications
      context.read<NotificationBloc>().add(NotificationsRefreshedEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const AutoLeadingButton(),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.canMarkAsRead) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: () {
                    context
                        .read<NotificationBloc>()
                        .add(NotificationMarkAllAsReadEvent());
                  },
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // Show success message when all marked as read
          state.markAllAsReadState.maybeMap(
            success: (s) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marked ${s.data} notifications as read'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            failure: (f) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(f.failure.message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.notificationsState.map(
            initial: (_) => const NotificationLoadingShimmer(),
            loading: (_) => const NotificationLoadingShimmer(),
            success: (s) => _buildSuccessContent(context, state, s.data),
            failure: (f) => _buildErrorContent(context, f.failure),
            refreshing: (r) =>
                _buildSuccessContent(context, state, r.currentData),
          );
        },
      ),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    NotificationState state,
    NotificationsResponse data,
  ) {
    if (data.grouped.getTotalCount() == 0) {
      return const EmptyNotificationsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(NotificationsRefreshedEvent());
        await context.read<NotificationBloc>().stream.firstWhere(
              (state) => !state.isRefreshing,
            );
      },
      child: NotificationList(
        grouped: data.grouped,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoadingMore,
        onLoadMore: () {
          context.read<NotificationBloc>().add(NotificationsLoadMoreEvent());
        },
        onNotificationTap: (notification) {
          // Handle actionUrl navigation (follow banner pattern)
          if (notification.actionUrl != null) {
            BannerNavigationHandler.handleNavigation(
              context,
              notification.actionUrl!,
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Failure failure) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationBloc>().add(NotificationsLoadedEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**2. Widgets** (`lib/notifications/view/widgets/`)

See detailed widget implementations in sections below...

---

#### **C. Widgets Implementation**

**1. `notification_list.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/notifications/view/widgets/notification_item.dart';
import 'package:app_ui/app_ui.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({
    required this.grouped,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onNotificationTap,
    super.key,
  });

  final GroupedNotifications grouped;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final void Function(Notification) onNotificationTap;

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom && widget.hasMore && !widget.isLoadingMore) {
      widget.onLoadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9); // Trigger at 90%
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Today section
        if (widget.grouped.today.isNotEmpty) ...[
          const _SectionHeader(title: 'Today'),
          ...widget.grouped.today.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => widget.onNotificationTap(notification),
            ),
          ),
        ],

        // Yesterday section
        if (widget.grouped.yesterday.isNotEmpty) ...[
          const _SectionHeader(title: 'Yesterday'),
          ...widget.grouped.yesterday.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => widget.onNotificationTap(notification),
            ),
          ),
        ],

        // This Week section
        if (widget.grouped.thisWeek.isNotEmpty) ...[
          const _SectionHeader(title: 'This Week'),
          ...widget.grouped.thisWeek.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => widget.onNotificationTap(notification),
            ),
          ),
        ],

        // This Month section
        if (widget.grouped.thisMonth.isNotEmpty) ...[
          const _SectionHeader(title: 'This Month'),
          ...widget.grouped.thisMonth.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => widget.onNotificationTap(notification),
            ),
          ),
        ],

        // Older section
        if (widget.grouped.older.isNotEmpty) ...[
          const _SectionHeader(title: 'Older'),
          ...widget.grouped.older.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => widget.onNotificationTap(notification),
            ),
          ),
        ],

        // Loading more indicator
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: AppColors.grey,
        ),
      ),
    );
  }
}
```

**2. `notification_item.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:app_ui/app_ui.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Icon
            _buildAvatar(),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.caption,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.timeAgo,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (notification.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(notification.imageUrl!),
        backgroundColor: Colors.grey.shade200,
      );
    }

    // Default icon based on type
    return CircleAvatar(
      radius: 24,
      backgroundColor: _getIconBackgroundColor(),
      child: Icon(
        _getIconForType(),
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Color _getIconBackgroundColor() {
    // Map notification types to colors
    switch (notification.type.toLowerCase()) {
      case 'order':
        return Colors.green;
      case 'promo':
        return Colors.orange;
      case 'reminder':
        return Colors.red.shade400;
      case 'system':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForType() {
    switch (notification.type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'reminder':
        return Icons.notifications_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
```

**3. `empty_notifications_state.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Icon(
              Icons.notifications_none_outlined,
              size: 120,
              color: AppColors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ll notify you when something new arrives',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

**4. `notification_loading_shimmer.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';

class NotificationLoadingShimmer extends StatelessWidget {
  const NotificationLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Avatar shimmer
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

### **Phase 3: Home Screen Integration**

#### **A. Update HomeBloc**

**Add event to `home_event.dart`:**
```dart
/// Update notification badge counts
final class HomeNotificationBadgeUpdatedEvent extends HomeEvent {
  const HomeNotificationBadgeUpdatedEvent({
    required this.unreadCount,
    required this.hasUnread,
  });

  final int unreadCount;
  final bool hasUnread;
}
```

**Add handler to `home_bloc.dart`:**
```dart
Future<void> _onNotificationBadgeUpdated(
  HomeNotificationBadgeUpdatedEvent event,
  Emitter<HomeState> emit,
) async {
  final currentData = state.homePageData;
  if (currentData != null) {
    // Create updated home page data with new badge counts
    final updatedData = HomePageData(
      banners: currentData.banners,
      categories: currentData.categories,
      hasUnreadNotifications: event.hasUnread,
      unreadCount: event.unreadCount,
    );

    emit(
      state.copyWith(
        homePageState: DataState.success(updatedData),
      ),
    );
  }
}
```

**Register handler in constructor:**
```dart
on<HomeNotificationBadgeUpdatedEvent>(_onNotificationBadgeUpdated);
```

---

#### **B. Update HomeScreen AppBar**

**In `home_screen.dart`, update the notification icon:**
```dart
// In _AppBarSection's actions
IconButton(
  icon: Stack(
    clipBehavior: Clip.none,
    children: [
      const Icon(Icons.notifications_outlined),
      if (state.homePageData?.hasUnreadNotifications ?? false)
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              '${state.homePageData?.unreadCount ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  ),
  onPressed: () {
    context.router.push(const NotificationsRoute());
  },
  tooltip: 'Notifications',
),
```

---

### **Phase 4: Routing**

#### **A. Add Route to `router.dart`**

```dart
AutoRoute(page: NotificationsRoute.page),
```

#### **B. Generate Route Code**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **Phase 5: Dependency Injection**

#### **Update `app.dart`**

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider(create: (_) => widget.api.cmsFacade),
    RepositoryProvider(create: (_) => widget.api.authFacade),
    RepositoryProvider(create: (_) => widget.api.menuFacade),
    RepositoryProvider(create: (_) => widget.api.dashboardRepo),
    RepositoryProvider(create: (_) => widget.api.notificationsFacade), // ADD THIS
  ],
  child: ...,
)
```

---

## 🔄 Badge Update Strategy (Hybrid Approach)

### **Flow:**

1. **Optimistic Update** - When user taps "Mark all as read":
   - Immediately update HomeBloc state to set `unreadCount = 0`, `hasUnreadNotifications = false`
   - User sees instant badge removal
   
2. **API Call** - Trigger mark-all-as-read API:
   - On success: Keep optimistic update, mark local notifications as read
   - On failure: Show error, trigger home refresh to restore accurate state

3. **Background Refresh** - When user navigates back to home:
   - Trigger background refresh using `DataState.refreshing()` pattern
   - Ensures data stays in sync

4. **App Lifecycle** - When app comes to foreground:
   - Refresh home data in background
   - Refresh notifications if on notifications screen

---

## 📱 Real-time Updates Strategy

### **Multi-layered Approach:**

1. **Background Polling** (30-second interval)
   - Timer in NotificationBloc polls for new notifications
   - Uses `DataState.refreshing()` to avoid UI disruption

2. **App Lifecycle Listener**
   - Refresh when app comes to foreground
   - Implemented in notifications screen

3. **Manual Refresh**
   - Pull-to-refresh available
   - User can manually trigger refresh

4. **On Screen Entry**
   - Load fresh data when navigating to notifications screen

---

## ✅ Implementation Checklist

### **Phase 1: API Layer**
- [ ] Create `packages/instamess_api/lib/src/notifications/` directory
- [ ] Create `models/` subdirectory
- [ ] Implement `notification.dart` model
- [ ] Implement `notification_pagination.dart` model
- [ ] Implement `grouped_notifications.dart` model
- [ ] Implement `notifications_response.dart` model
- [ ] Create `models.dart` barrel file
- [ ] Create `notifications_facade_interface.dart`
- [ ] Implement `notifications_repository.dart`
- [ ] Create `notifications.dart` barrel file
- [ ] Update `instamess_api.dart` to expose `notificationsFacade`
- [ ] Export notifications module in main `instamess_api.dart`

### **Phase 2: Feature Layer**
- [ ] Create `lib/notifications/` directory structure
- [ ] Create `bloc/` subdirectory
- [ ] Implement `notification_event.dart` (sealed events)
- [ ] Implement `notification_state.dart` (with DataState)
- [ ] Implement `notification_bloc.dart` (event handlers + polling)
- [ ] Create `view/` subdirectory
- [ ] Implement `notifications_screen.dart` with `@RoutePage()`
- [ ] Create `widgets/` subdirectory
- [ ] Implement `notification_list.dart` with infinite scroll
- [ ] Implement `notification_item.dart` with design
- [ ] Implement `empty_notifications_state.dart`
- [ ] Implement `notification_loading_shimmer.dart`

### **Phase 3: Home Integration**
- [ ] Add `HomeNotificationBadgeUpdatedEvent` to HomeBloc
- [ ] Implement badge update handler in HomeBloc
- [ ] Update HomeScreen AppBar notification icon with badge
- [ ] Add navigation to NotificationsRoute on icon tap

### **Phase 4: Routing**
- [ ] Add `NotificationsRoute` to `lib/router/router.dart`
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify route generation

### **Phase 5: Dependency Injection**
- [ ] Add `RepositoryProvider` for `INotificationsRepository` in `app.dart`
- [ ] Verify BLoC can access repository

### **Phase 6: Testing & Polish**
- [ ] Test empty state
- [ ] Test loading state
- [ ] Test error state with retry
- [ ] Test pull-to-refresh
- [ ] Test infinite scroll
- [ ] Test mark-all-as-read
- [ ] Test badge updates
- [ ] Test navigation to actionUrl
- [ ] Test app lifecycle refresh
- [ ] Test background polling
- [ ] Verify data persistence across navigation

---

## 🎨 Design Implementation Notes

### **Colors:**
- **Unread indicator**: `AppColors.primary` (blue dot)
- **Error background**: `AppColors.error`
- **Section headers**: `AppColors.grey`
- **Description text**: `AppColors.grey`

### **Typography:**
- **Caption**: `context.textTheme.bodyLarge` with `fontWeight: FontWeight.w600`
- **Description**: `context.textTheme.bodyMedium` with `color: AppColors.grey`
- **Time ago**: `context.textTheme.bodySmall` with `color: AppColors.grey`
- **Section headers**: `context.textTheme.titleSmall` with `color: AppColors.grey`

### **Spacing:**
- List padding: `8.0` vertical
- Item padding: `20.0` horizontal, `12.0` vertical
- Section header padding: `20.0` horizontal, `16.0` top, `8.0` bottom
- Avatar size: `48.0` diameter (radius: `24.0`)
- Unread dot: `8.0` diameter

---

## 🚀 Next Steps

1. Review and approve this plan
2. Clarify any remaining questions
3. Begin implementation starting with Phase 1 (API Layer)
4. Test incrementally after each phase
5. Iterate based on feedback

---

**Document Version:** 1.0  
**Last Updated:** October 31, 2025  
**Status:** Ready for Implementation
