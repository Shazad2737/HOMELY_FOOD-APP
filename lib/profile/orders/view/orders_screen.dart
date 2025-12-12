import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/orders/bloc/orders_bloc.dart';
import 'package:instamess_app/profile/orders/view/widgets/widgets.dart';

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
      backgroundColor: AppColors.white,
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
          OrdersOngoingTab(scrollController: _ongoingScrollController),
          OrdersHistoryTab(scrollController: _historyScrollController),
        ],
      ),
    );
  }
}
