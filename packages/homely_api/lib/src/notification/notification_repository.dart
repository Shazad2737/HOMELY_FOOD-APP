import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/notification/i_notification_repository.dart';
import 'package:homely_api/src/notification/models/models.dart';

/// {@template notification_repository}
/// Repository for notification-related operations
/// {@endtemplate}
class NotificationRepository implements INotificationRepository {
  /// {@macro notification_repository}
  const NotificationRepository({
    required this.apiClient,
  });

  /// Api client
  final ApiClient apiClient;

  @override
  Future<Either<Failure, NotificationData>> getNotifications({
    String? type,
    int? page,
    int? limit,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await apiClient.get<Map<String, dynamic>>(
        'notification',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.fold(
        (apiFailure) {
          log('Error fetching notifications: $apiFailure');
          return left(apiFailure);
        },
        (response) {
          final body = response.data;
          if (body == null) {
            return left(
              const UnknownApiFailure(
                0,
                'No notification data received',
              ),
            );
          }

          try {
            final success = body['success'] as bool? ?? false;
            if (!success) {
              final message =
                  body['message'] as String? ?? 'Failed to fetch notifications';
              return left(UnknownApiFailure(response.statusCode ?? 0, message));
            }

            final data = body['data'] as Map<String, dynamic>?;
            if (data == null) {
              return left(
                const UnknownApiFailure(0, 'No notification data in response'),
              );
            }

            final notificationData = NotificationData.fromJson(data);
            return right(notificationData);
          } catch (e, s) {
            log('Error parsing notification response: $e', stackTrace: s);
            return left(
              const UnknownApiFailure(
                0,
                'Failed to parse notification data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log('Unexpected error in getNotifications: $e', stackTrace: s);
      return left(
        const UnknownFailure(
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        'notification/read-all',
      );

      return response.fold(
        (apiFailure) {
          log('Error marking notifications as read: $apiFailure');
          return left(apiFailure);
        },
        (response) {
          final body = response.data;
          if (body == null) {
            return left(
              const UnknownApiFailure(
                0,
                'No response data received',
              ),
            );
          }

          try {
            final success = body['success'] as bool? ?? false;
            if (!success) {
              final message = body['message'] as String? ??
                  'Failed to mark notifications as read';
              return left(UnknownApiFailure(response.statusCode ?? 0, message));
            }

            final data = body['data'] as Map<String, dynamic>?;
            final count = data?['count'] as int? ?? 0;
            return right(count);
          } catch (e, s) {
            log('Error parsing mark-all-as-read response: $e', stackTrace: s);
            return left(
              const UnknownApiFailure(
                0,
                'Failed to parse response',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log('Unexpected error in markAllAsRead: $e', stackTrace: s);
      return left(
        const UnknownFailure(
          message: 'An unexpected error occurred',
        ),
      );
    }
  }
}
