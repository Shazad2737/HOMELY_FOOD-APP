import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/notification/models/models.dart';

/// {@template notification_repository_interface}
/// Interface for Notification operations
/// {@endtemplate}
abstract class INotificationRepository {
  /// Get notifications
  ///
  /// [type] - Optional notification type filter
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  Future<Either<Failure, NotificationData>> getNotifications({
    String? type,
    int? page,
    int? limit,
  });

  /// Mark all notifications as read
  Future<Either<Failure, int>> markAllAsRead();
}
