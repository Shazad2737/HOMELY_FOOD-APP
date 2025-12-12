import 'package:equatable/equatable.dart';
import 'package:homely_api/src/notification/models/grouped_notifications.dart';
import 'package:homely_api/src/notification/models/pagination.dart';

/// {@template notification_data}
/// Complete notification data with grouping and pagination
/// {@endtemplate}
class NotificationData extends Equatable {
  /// {@macro notification_data}
  const NotificationData({
    required this.grouped,
    required this.pagination,
  });

  /// Parse from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    final groupedJson = json['grouped'] as Map<String, dynamic>? ?? {};
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};

    return NotificationData(
      grouped: GroupedNotifications.fromJson(groupedJson),
      pagination: Pagination.fromJson(paginationJson),
    );
  }

  /// Grouped notifications by day category
  final GroupedNotifications grouped;

  /// Pagination information
  final Pagination pagination;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'grouped': grouped.toJson(),
      'pagination': pagination.toJson(),
    };
  }

  @override
  List<Object?> get props => [grouped, pagination];
}
