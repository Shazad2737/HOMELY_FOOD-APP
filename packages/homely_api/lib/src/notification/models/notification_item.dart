import 'package:equatable/equatable.dart';

/// {@template notification_item}
/// A single notification item
/// {@endtemplate}
class NotificationItem extends Equatable {
  /// {@macro notification_item}
  const NotificationItem({
    required this.id,
    required this.caption,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.priority,
    required this.actionUrl,
    required this.sentAt,
    required this.timeAgo,
    required this.dayCategory,
    required this.isRead,
    required this.readAt,
  });

  /// Parse from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      caption: json['caption'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String? ?? '',
      priority: json['priority']?.toString() ?? '',
      actionUrl: json['actionUrl'] as String?,
      sentAt: json['sentAt'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
      dayCategory: json['dayCategory'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
    );
  }

  /// Notification ID
  final String id;

  /// Notification title/caption
  final String caption;

  /// Notification description (optional)
  final String? description;

  /// Image URL (optional)
  final String? imageUrl;

  /// Notification type
  final String type;

  /// Priority (string or number)
  final String priority;

  /// Action URL (optional)
  final String? actionUrl;

  /// Sent at timestamp
  final String sentAt;

  /// Human-readable relative time
  final String timeAgo;

  /// Day category (today, yesterday, this_week, this_month, older)
  final String dayCategory;

  /// Whether the notification has been read
  final bool isRead;

  /// Read at timestamp (optional)
  final String? readAt;

  /// Convert to JSON
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
