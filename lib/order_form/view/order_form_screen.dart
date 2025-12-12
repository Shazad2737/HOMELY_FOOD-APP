import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';
import 'package:homely_app/order_form/view/helpers/next_available_date_calculator.dart';
import 'package:homely_app/order_form/view/widgets/error_content_widget.dart';
import 'package:homely_app/order_form/view/widgets/no_address_screen.dart';
import 'package:homely_app/order_form/view/widgets/order_form_content/order_form_content_widget.dart';
import 'package:homely_app/order_form/view/widgets/widgets.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_bloc.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_event.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_state.dart';
import 'package:homely_app/router/router.gr.dart';

/// {@template order_form_screen}
/// Screen for creating a new food order
/// {@endtemplate}
@RoutePage()
class OrderFormScreen extends StatefulWidget {
  /// {@macro order_form_screen}
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  @override
  void initState() {
    super.initState();
    // Load addresses when order form screen is first opened
    context.read<AddressesBloc>().add(const AddressesLoadedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderFormBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(const OrderFormLoadedEvent()),
      child: const _OrderFormGuard(),
    );
  }
}

/// {@template order_form_guard}
/// Guard that checks if user has addresses before showing order form
/// {@endtemplate}
class _OrderFormGuard extends StatelessWidget {
  /// {@macro order_form_guard}
  const _OrderFormGuard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesBloc, AddressesState>(
      builder: (context, addressesState) {
        return addressesState.addressesState.map(
          initial: (_) => _buildScaffold(const _LoadingIndicator()),
          loading: (_) => _buildScaffold(const _LoadingIndicator()),
          failure: (f) => _buildScaffold(
            _AddressesErrorContent(failure: f.failure),
          ),
          refreshing: (r) => _handleAddressesData(r.currentData.addresses),
          success: (s) => _handleAddressesData(s.data.addresses),
        );
      },
    );
  }

  Widget _buildScaffold(Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _handleAddressesData(List<CustomerAddress> addresses) {
    if (addresses.isEmpty) {
      return _buildScaffold(const NoAddressScreen());
    }
    return const OrderFormView();
  }
}

/// Error content for address loading failures
class _AddressesErrorContent extends StatelessWidget {
  const _AddressesErrorContent({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load addresses',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<AddressesBloc>().add(const AddressesLoadedEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template order_form_body}
/// Body widget that handles all states: subscription → available days
/// {@endtemplate}
class _OrderFormBody extends StatelessWidget {
  const _OrderFormBody({required this.state});

  final OrderFormState state;

  @override
  Widget build(BuildContext context) {
    // Step 1: Handle subscription state first
    return state.subscriptionState.map(
      initial: (_) => const _LoadingIndicator(),
      loading: (_) => const _LoadingIndicator(),
      failure: (f) => _SubscriptionErrorContent(failure: f.failure),
      refreshing: (r) => _buildAvailableDaysContent(context, r.currentData),
      success: (s) => _buildAvailableDaysContent(context, s.data),
    );
  }

  Widget _buildAvailableDaysContent(
    BuildContext context,
    SubscriptionData subscriptionData,
  ) {
    // Step 2: Check if user has active subscription
    if (!subscriptionData.hasSubscribedMeals) {
      return NoSubscriptionScreen(subscriptionData: subscriptionData);
    }

    // Step 3: Handle available days state
    return state.availableDaysState.map(
      initial: (_) => const _LoadingIndicator(),
      loading: (_) => const _LoadingIndicator(),
      failure: (f) => ErrorContentWidget(failure: f.failure),
      refreshing: (r) => _buildOrderForm(context, r.currentData),
      success: (s) => _buildOrderForm(context, s.data),
    );
  }

  Widget _buildOrderForm(BuildContext context, AvailableOrderDays data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderFormBloc>().add(const OrderFormRefreshedEvent());
        // Wait for refresh to complete
        await context.read<OrderFormBloc>().stream.firstWhere(
          (s) =>
              !s.subscriptionState.isRefreshing &&
              !s.availableDaysState.isRefreshing,
        );
      },
      child: OrderFormContentWidget(state: state, data: data),
    );
  }
}

/// Loading indicator widget
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Error content for subscription failures with retry
class _SubscriptionErrorContent extends StatelessWidget {
  const _SubscriptionErrorContent({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load subscription',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<OrderFormBloc>().add(const OrderFormLoadedEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template order_form_view}
/// View for order form screen
/// {@endtemplate}
class OrderFormView extends StatelessWidget {
  /// {@macro order_form_view}
  const OrderFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderFormBloc, OrderFormState>(
      listenWhen: (previous, current) {
        // Listen on transitions to success or failure for order creation
        return previous.createOrderState != current.createOrderState &&
            current.createOrderState.maybeMap(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            );
      },
      listener: (context, state) {
        state.createOrderState.maybeMap(
          success: (s) => _showSuccessDialog(context, s.data),
          failure: (f) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(f.failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: const Text('New Order'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
          ),
          body: _OrderFormBody(state: state),
          bottomNavigationBar: _shouldShowBottomBar(state)
              ? const BottomSubmitSection()
              : null,
        );
      },
    );
  }

  bool _shouldShowBottomBar(OrderFormState state) {
    // Only show bottom bar when we have active subscription and available days
    final hasSubscription = state.subscriptionState.maybeMap(
      success: (s) => s.data.hasSubscribedMeals,
      refreshing: (r) => r.currentData.hasSubscribedMeals,
      orElse: () => false,
    );

    final hasAvailableDays = state.availableDaysState.maybeMap(
      success: (_) => true,
      refreshing: (_) => true,
      orElse: () => false,
    );

    return hasSubscription && hasAvailableDays;
  }

  void _showSuccessDialog(BuildContext context, CreateOrderResponse order) {
    final bloc = context.read<OrderFormBloc>();

    // Show dialog after a brief delay to ensure proper rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh available days to reflect the new order
      bloc.add(const OrderFormLoadedEvent());

      // Get the next available date info
      final state = bloc.state;
      final nextAvailableInfo = NextAvailableDateCalculator.calculate(state);

      // Capture meal selections for location display
      // (workaround since API doesn't return deliveryLocation)
      final mealSelections = state.mealSelections;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => OrderSuccessDialog(
          order: order,
          mealSelections: mealSelections,
          nextAvailableDateLabel: nextAvailableInfo.label,
          showRepeatButton: nextAvailableInfo.canRepeat,
          onCloseSelectNextAvailable: () {
            Navigator.of(dialogContext).pop();

            if (nextAvailableInfo.canRepeat) {
              context.read<OrderFormBloc>().add(
                OrderFormDateSelectedEvent(
                  nextAvailableInfo.date,
                  keepSelections: true,
                ),
              );
            } else {
              context.read<OrderFormBloc>()
                ..add(const OrderFormDateClearedEvent())
                ..add(OrderFormDateSelectedEvent(nextAvailableInfo.date));
            }
          },
          onRepeatForNextAvailable: nextAvailableInfo.canRepeat
              ? () {
                  Navigator.of(dialogContext).pop();
                  // Change date while keeping selections
                  context.read<OrderFormBloc>().add(
                    OrderFormDateSelectedEvent(
                      nextAvailableInfo.date,
                      keepSelections: true,
                    ),
                  );
                }
              : null,
          onOrderNextAvailable: () {
            Navigator.of(dialogContext).pop();
            // Clear current selections and select next available date
            context.read<OrderFormBloc>()
              ..add(const OrderFormDateClearedEvent())
              ..add(OrderFormDateSelectedEvent(nextAvailableInfo.date));
          },
          onViewAllOrders: () {
            Navigator.of(dialogContext).pop();

            context.router.push(const OrdersRoute());
          },
        ),
      );
    });
  }
}
