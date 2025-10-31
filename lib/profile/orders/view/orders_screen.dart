import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/orders/bloc/orders_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(const OrdersOngoingLoadedEvent()),
      child: const OrdersView(),
    );
  }
}

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ongoingScrollController = ScrollController();
  final _historyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load history when history tab is first selected
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        final state = context.read<OrdersBloc>().state;
        if (state.historyOrdersState is DataStateInitial) {
          context.read<OrdersBloc>().add(const OrdersHistoryLoadedEvent());
        }
      }
    });

    // Setup scroll listeners for pagination
    _ongoingScrollController.addListener(_onOngoingScroll);
    _historyScrollController.addListener(_onHistoryScroll);
  }

  void _onOngoingScroll() {
    if (_ongoingScrollController.position.pixels >=
        _ongoingScrollController.position.maxScrollExtent - 200) {
      context.read<OrdersBloc>().add(const OrdersOngoingLoadMoreEvent());
    }
  }

  void _onHistoryScroll() {
    if (_historyScrollController.position.pixels >=
        _historyScrollController.position.maxScrollExtent - 200) {
      context.read<OrdersBloc>().add(const OrdersHistoryLoadMoreEvent());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ongoingScrollController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.appRed,
          labelColor: AppColors.appRed,
          unselectedLabelColor: AppColors.grey600,
          labelStyle: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OngoingTab(scrollController: _ongoingScrollController),
          _HistoryTab(scrollController: _historyScrollController),
        ],
      ),
    );
  }
}

class _OngoingTab extends StatelessWidget {
  const _OngoingTab({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return state.ongoingOrdersState.map(
          initial: (_) => const Center(child: Text('Loading...')),
          loading: (_) => const Center(child: CircularProgressIndicator()),
          success: (successState) {
            final response = successState.data;
            if (response.data.isEmpty) {
              return const _EmptyState(message: 'No ongoing orders');
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersBloc>().add(
                  const OrdersOngoingRefreshedEvent(),
                );
                await Future<void>.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    response.data.length +
                    (state.ongoingHasMore ? 1 : 0), // +1 for loader
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
                  return _OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
          failure: (failureState) => _ErrorContent(
            message: failureState.failure.message,
            onRetry: () {
              context.read<OrdersBloc>().add(const OrdersOngoingLoadedEvent());
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
                  return _OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.scrollController});

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
              return const _EmptyState(message: 'No order history');
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
                  return _OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
          failure: (failureState) => _ErrorContent(
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
                  return _OrderGroupCard(orderGroup: orderGroup);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _OrderGroupCard extends StatelessWidget {
  const _OrderGroupCard({required this.orderGroup});

  final OrderGroup orderGroup;

  @override
  Widget build(BuildContext context) {
    // Assuming one order per group based on the design
    final order = orderGroup.orders.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.appRed,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Header with ID and Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.appRed,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${order.orderNumber}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.appRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Date: ${_formatDate(order.orderDate)}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.appRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Order Items
            ...order.orderItems.map(
              (OrderItem item) => _OrderItemCard(item: item),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final foodItem = item.foodItem;
    final mealType = item.mealType;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          if (foodItem.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                foodItem.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: AppColors.grey200,
                    child: const Icon(Icons.restaurant, size: 48),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, size: 48),
              ),
            ),
          const SizedBox(height: 16),
          // Food Name
          Text(
            foodItem.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Description with icon
          if (foodItem.description != null) ...[
            _InfoRow(
              icon: Icons.restaurant,
              text: foodItem.description!,
            ),
            const SizedBox(height: 8),
          ],
          // Cuisine
          if (foodItem.cuisine != null) ...[
            _InfoRow(
              icon: Icons.set_meal_outlined,
              text: 'Cuisine: ${foodItem.cuisine}',
            ),
            const SizedBox(height: 8),
          ],
          // Style
          if (foodItem.style != null) ...[
            _InfoRow(
              icon: Icons.style_outlined,
              text: 'Style: ${foodItem.style}',
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          // Delivery Time
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: AppColors.appGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Delivery is scheduled between ${mealType.startTime} and ${mealType.endTime}.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.appGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.appRed,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
