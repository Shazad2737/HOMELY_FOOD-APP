import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/helpers/next_available_date_calculator.dart';
import 'package:instamess_app/order_form/view/widgets/error_content_widget.dart';
import 'package:instamess_app/order_form/view/widgets/order_form_content/order_form_content_widget.dart';
import 'package:instamess_app/order_form/view/widgets/widgets.dart';

/// {@template order_form_screen}
/// Screen for creating a new food order
/// {@endtemplate}
@RoutePage()
class OrderFormScreen extends StatelessWidget {
  /// {@macro order_form_screen}
  const OrderFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderFormBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(const OrderFormLoadedEvent()),
      child: const OrderFormView(),
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
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: AppBar(
            title: const Text('New Order'),
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
          ),
          body: state.availableDaysState.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            success: (s) => OrderFormContentWidget(state: state, data: s.data),
            failure: (f) => ErrorContentWidget(failure: f.failure),
            refreshing: (r) =>
                OrderFormContentWidget(state: state, data: r.currentData),
          ),
          bottomNavigationBar: const BottomSubmitSection(),
        );
      },
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
          onViewDetails: () {
            Navigator.of(dialogContext).pop();
            // TODO: Navigate to order details screen when implemented
            // For now, just go back to home
            context.router.maybePop();
          },
        ),
      );
    });
  }
}
