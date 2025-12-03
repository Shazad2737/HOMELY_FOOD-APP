import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/helpers/next_available_date_calculator.dart';
import 'package:instamess_app/order_form/view/widgets/error_content_widget.dart';
import 'package:instamess_app/order_form/view/widgets/no_address_screen.dart';
import 'package:instamess_app/order_form/view/widgets/order_form_content/order_form_content_widget.dart';
import 'package:instamess_app/order_form/view/widgets/widgets.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_bloc.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_event.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_state.dart';
import 'package:instamess_app/router/router.gr.dart';

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
        // Check if user has any addresses
        final hasAddresses = addressesState.addressesState.maybeMap(
          success: (s) => s.data.addresses.isNotEmpty,
          refreshing: (r) => r.currentData.addresses.isNotEmpty,
          orElse: () => false,
        );

        // Show loading while checking addresses
        final isLoadingAddresses = addressesState.addressesState.maybeMap(
          initial: (_) => true,
          loading: (_) => true,
          orElse: () => false,
        );

        if (isLoadingAddresses) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Order'),
              centerTitle: false,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Block order form if user has no addresses
        if (!hasAddresses) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Order'),
              centerTitle: false,
            ),
            body: const NoAddressScreen(),
          );
        }

        // User has addresses, show normal order form
        return const OrderFormView();
      },
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
        // Only listen when createOrderState changes (prevents infinite loop)
        // Listen on transitions to success or failure
        return previous.createOrderState != current.createOrderState &&
            current.createOrderState.maybeMap(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            );
      },
      listener: (context, state) {
        // Handle order creation success
        state.createOrderState.maybeMap(
          success: (s) {
            // Show success dialog instead of just snackbar
            _showSuccessDialog(context, s.data);
          },
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
        // Check subscription state first
        final isLoadingSubscription = state.subscriptionState.maybeMap(
          initial: (_) => true,
          loading: (_) => true,
          orElse: () => false,
        );

        final hasNoSubscription = state.subscriptionState.maybeMap(
          success: (s) => !s.data.hasSubscribedMeals,
          orElse: () => false,
        );

        // Get subscription data for NoSubscriptionScreen
        final subscriptionData = state.subscriptionState.maybeMap(
          success: (s) => s.data,
          refreshing: (r) => r.currentData,
          orElse: () => null,
        );

        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: const Text('New Order'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
          ),
          body: _buildBody(
            context,
            state,
            isLoadingSubscription,
            hasNoSubscription,
            subscriptionData,
          ),
          // Hide bottom bar when no subscription or loading
          bottomNavigationBar: (isLoadingSubscription || hasNoSubscription)
              ? null
              : const BottomSubmitSection(),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderFormState state,
    bool isLoadingSubscription,
    bool hasNoSubscription,
    SubscriptionData? subscriptionData,
  ) {
    // Show loading while checking subscription
    if (isLoadingSubscription) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show no subscription screen if user has no active subscription
    if (hasNoSubscription) {
      return NoSubscriptionScreen(subscriptionData: subscriptionData);
    }

    // Show available days state
    return state.availableDaysState.map(
      initial: (_) => const Center(child: CircularProgressIndicator()),
      loading: (_) => const Center(child: CircularProgressIndicator()),
      success: (s) => RefreshIndicator(
        onRefresh: () async {
          context.read<OrderFormBloc>().add(
            const OrderFormRefreshedEvent(),
          );
          // Wait for the refresh to complete
          await context.read<OrderFormBloc>().stream.firstWhere(
            (state) => !state.availableDaysState.isRefreshing,
          );
        },
        child: OrderFormContentWidget(state: state, data: s.data),
      ),
      failure: (f) => ErrorContentWidget(failure: f.failure),
      refreshing: (r) => RefreshIndicator(
        onRefresh: () async {
          // Already refreshing, just wait for completion
          await context.read<OrderFormBloc>().stream.firstWhere(
            (state) => !state.availableDaysState.isRefreshing,
          );
        },
        child: OrderFormContentWidget(state: state, data: r.currentData),
      ),
    );
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
