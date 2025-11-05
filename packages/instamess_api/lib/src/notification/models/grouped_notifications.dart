import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/notification/models/notification_item.dart';

/// {@template grouped_notifications}
/// Notifications grouped by day categories
/// {@endtemplate}
class GroupedNotifications extends Equatable {
  /// {@macro grouped_notifications}
  const GroupedNotifications({
    required this.today,
    required this.yesterday,
    required this.thisWeek,
    required this.thisMonth,
    required this.older,
  });

  /// Parse from JSON
  factory GroupedNotifications.fromJson(Map<String, dynamic> json) {
    return GroupedNotifications(
      today: (json['today'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      yesterday: (json['yesterday'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      thisWeek: (json['this_week'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      thisMonth: (json['this_month'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      older: (json['older'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Notifications from today
  final List<NotificationItem> today;

  /// Notifications from yesterday
  final List<NotificationItem> yesterday;

  /// Notifications from this week
  final List<NotificationItem> thisWeek;

  /// Notifications from this month
  final List<NotificationItem> thisMonth;

  /// Older notifications
  final List<NotificationItem> older;

  /// Get all notifications as a flat list
  List<NotificationItem> get all => [
        ...today,
        ...yesterday,
        ...thisWeek,
        ...thisMonth,
        ...older,
      ];

  /// Check if there are any notifications
  bool get isEmpty =>
      today.isEmpty &&
      yesterday.isEmpty &&
      thisWeek.isEmpty &&
      thisMonth.isEmpty &&
      older.isEmpty;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'today': today.map((e) => e.toJson()).toList(),
      'yesterday': yesterday.map((e) => e.toJson()).toList(),
      'this_week': thisWeek.map((e) => e.toJson()).toList(),
      'this_month': thisMonth.map((e) => e.toJson()).toList(),
      'older': older.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [today, yesterday, thisWeek, thisMonth, older];
}
