import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template notification_item_widget}
/// A widget to display a single notification item
/// {@endtemplate}
class NotificationItemWidget extends StatelessWidget {
  /// {@macro notification_item_widget}
  const NotificationItemWidget({
    required this.notification,
    super.key,
  });

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: notification.isRead
          ? null
          : BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon or Image
          _buildLeadingIcon(context),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                if (notification.description != null &&
                    notification.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.description!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ],
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
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    // If there's an image URL, show it
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(notification.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Otherwise show an icon based on type
    IconData iconData;
    Color backgroundColor;

    switch (notification.type.toLowerCase()) {
      case 'order':
        iconData = Icons.shopping_bag_outlined;
        backgroundColor = AppColors.primary.withOpacity(0.1);
      case 'delivery':
        iconData = Icons.delivery_dining;
        backgroundColor = Colors.green.withOpacity(0.1);
      case 'reminder':
        iconData = Icons.notifications_outlined;
        backgroundColor = Colors.orange.withOpacity(0.1);
      default:
        iconData = Icons.notifications_outlined;
        backgroundColor = AppColors.grey600.withOpacity(0.1);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: backgroundColor == AppColors.primary.withOpacity(0.1)
            ? AppColors.primary
            : backgroundColor == Colors.green.withOpacity(0.1)
            ? Colors.green
            : backgroundColor == Colors.orange.withOpacity(0.1)
            ? Colors.orange
            : AppColors.grey600,
      ),
    );
  }
}
