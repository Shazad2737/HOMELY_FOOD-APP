import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/notifications/bloc/notifications_bloc.dart';
import 'package:instamess_app/notifications/view/widgets/notification_item_widget.dart';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutoRouteAwareStateMixin<NotificationsScreen> {
  @override
  void didPop() {
    super.didPop();
    // Mark all notifications as read when user leaves the screen
    // This ensures they've had a chance to view them
    if (mounted) {
      context.read<NotificationsBloc>().add(NotificationsMarkAllAsReadEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const NotificationsView();
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          return state.notificationsState.map(
            initial: (_) => const _LoadingState(),
            loading: (_) => const _LoadingState(),
            success: (s) => _SuccessState(data: s.data),
            failure: (f) => _ErrorState(failure: f.failure),
            refreshing: (r) => _SuccessState(data: r.currentData),
          );
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            failure.message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationsBloc>().add(
                NotificationsRefreshedEvent(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.data});

  final NotificationData data;

  @override
  Widget build(BuildContext context) {
    final grouped = data.grouped;

    // Check if there are any notifications
    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: AppColors.grey400.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(NotificationsRefreshedEvent());
        await context.read<NotificationsBloc>().stream.firstWhere(
          (state) => !state.isRefreshing,
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (grouped.today.isNotEmpty) ...[
            const _SectionHeader(title: 'Today'),
            ...grouped.today.map(
              (notification) => NotificationItemWidget(
                notification: notification,
              ),
            ),
          ],
          if (grouped.yesterday.isNotEmpty) ...[
            const _SectionHeader(title: 'Yesterday'),
            ...grouped.yesterday.map(
              (notification) => NotificationItemWidget(
                notification: notification,
              ),
            ),
          ],
          if (grouped.thisWeek.isNotEmpty) ...[
            const _SectionHeader(title: 'This Week'),
            ...grouped.thisWeek.map(
              (notification) => NotificationItemWidget(
                notification: notification,
              ),
            ),
          ],
          if (grouped.thisMonth.isNotEmpty) ...[
            const _SectionHeader(title: 'This Month'),
            ...grouped.thisMonth.map(
              (notification) => NotificationItemWidget(
                notification: notification,
              ),
            ),
          ],
          if (grouped.older.isNotEmpty) ...[
            const _SectionHeader(title: 'Older'),
            ...grouped.older.map(
              (notification) => NotificationItemWidget(
                notification: notification,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 16, 16),
      child: Row(
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              height: 1,
              color: AppColors.grey200,
            ),
          ),
        ],
      ),
    );
  }
}
