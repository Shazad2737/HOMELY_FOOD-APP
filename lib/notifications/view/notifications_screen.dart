import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/notifications/bloc/notifications_bloc.dart';
import 'package:instamess_app/notifications/view/widgets/notification_item_widget.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        notificationRepository: context.read<INotificationRepository>(),
      )
        ..add(NotificationsInitializedEvent())
        ..add(NotificationsMarkAllAsReadEvent()),
      child: const NotificationsView(),
    );
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
              context
                  .read<NotificationsBloc>()
                  .add(NotificationsRefreshedEvent());
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
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.grey,
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
        children: [
          if (grouped.today.isNotEmpty) ...[
            _SectionHeader(title: 'Today'),
            ...grouped.today.map((notification) => NotificationItemWidget(
                  notification: notification,
                )),
          ],
          if (grouped.yesterday.isNotEmpty) ...[
            _SectionHeader(title: 'Yesterday'),
            ...grouped.yesterday.map((notification) => NotificationItemWidget(
                  notification: notification,
                )),
          ],
          if (grouped.thisWeek.isNotEmpty) ...[
            _SectionHeader(title: 'This Week'),
            ...grouped.thisWeek.map((notification) => NotificationItemWidget(
                  notification: notification,
                )),
          ],
          if (grouped.thisMonth.isNotEmpty) ...[
            _SectionHeader(title: 'This Month'),
            ...grouped.thisMonth.map((notification) => NotificationItemWidget(
                  notification: notification,
                )),
          ],
          if (grouped.older.isNotEmpty) ...[
            _SectionHeader(title: 'Older'),
            ...grouped.older.map((notification) => NotificationItemWidget(
                  notification: notification,
                )),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      ),
    );
  }
}
