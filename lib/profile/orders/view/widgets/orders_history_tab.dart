import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_app/profile/orders/bloc/orders_bloc.dart';
import 'package:homely_app/profile/orders/view/widgets/empty_state.dart';
import 'package:homely_app/profile/orders/view/widgets/error_content.dart';
import 'package:homely_app/profile/orders/view/widgets/order_group_card.dart';

/// {@template orders_history_tab}
/// Tab view for displaying order history
/// {@endtemplate}
class OrdersHistoryTab extends StatelessWidget {
  /// {@macro orders_history_tab}
  const OrdersHistoryTab({
    required this.scrollController,
    super.key,
  });

  /// Scroll controller for pagination
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return state.historyOrdersState.map(
          initial: (_) => const Center(child: Text('Loading...')),
          loading: (_) => const Center(child: CircularProgressIndicator()),
          success: (successState) {
            final response = successState.data;
            if (response.data.isEmpty) {
              return const EmptyState(message: 'No order history');
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersBloc>().add(
                  const OrdersHistoryRefreshedEvent(),
                );
                await Future<void>.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    response.data.length +
                    (state.historyHasMore ? 1 : 0), // +1 for loader
                itemBuilder: (context, index) {
                  if (index >= response.data.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final orderGroup = response.data[index];
                  return OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
          failure: (failureState) => ErrorContent(
            message: failureState.failure.message,
            onRetry: () {
              context.read<OrdersBloc>().add(const OrdersHistoryLoadedEvent());
            },
          ),
          refreshing: (refreshingState) {
            final response = refreshingState.currentData;
            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: response.data.length,
                itemBuilder: (context, index) {
                  final orderGroup = response.data[index];
                  return OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
        );
      },
    );
  }
}
