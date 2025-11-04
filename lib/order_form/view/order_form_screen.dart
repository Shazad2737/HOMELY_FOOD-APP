import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_api/src/user/models/models.dart' as user_models;
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/widgets.dart';
import 'package:intl/intl.dart';

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
            success: (s) => _buildContent(context, state, s.data),
            failure: (f) => _buildError(context, f.failure),
            refreshing: (r) => _buildContent(context, state, r.currentData),
          ),
          bottomNavigationBar: const BottomSubmitSection(),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, Failure failure) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              'Failed to load order days',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<OrderFormBloc>().add(const OrderFormLoadedEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OrderFormState state,
    AvailableOrderDays data,
  ) {
    return CustomScrollView(
      slivers: [
        // Calendar section
        SliverToBoxAdapter(
          child: CalendarSection(days: data.days),
        ),

        // Content based on selected date
        if (!state.hasSelectedDate)
          const SliverFillRemaining(
            child: EmptyDatePrompt(),
          )
        else if (state.isSelectedDateHoliday && state.holidayName != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HolidayBanner(holidayName: state.holidayName!),
            ),
          )
        else if (state.isSelectedDateAlreadyOrdered &&
            state.existingOrderNumber != null &&
            state.existingOrderStatus != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AlreadyOrderedBanner(
                orderNumber: state.existingOrderNumber!,
                orderStatus: state.existingOrderStatus!,
              ),
            ),
          )
        else if (state.canShowMealCards) ...[
          // Selected date header
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: _buildSelectedDateHeader(context, state),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 8,
              color: AppColors.grey50,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: MealCardsSection(
                availableMealTypes: _getAvailableMealTypes(state, data),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedDateHeader(
    BuildContext context,
    OrderFormState state,
  ) {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return const SizedBox.shrink();

    final date = DateTime.parse(selectedDate);
    final dayName = _getDayName(date.weekday);
    final formattedDate =
        '${_getMonthName(date.month)} ${date.day}, ${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordering for',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dayName, $formattedDate',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Allow user to change date easily
                if (state.selectedMealCount > 0) {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Change Date?'),
                      content: const Text(
                        'This will clear your current meal selections. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<OrderFormBloc>().add(
                              const OrderFormDateClearedEvent(),
                            );
                          },
                          child: const Text('Change Date'),
                        ),
                      ],
                    ),
                  );
                } else {
                  context.read<OrderFormBloc>().add(
                    const OrderFormDateClearedEvent(),
                  );
                }
              },
              icon: const Icon(Icons.edit, color: AppColors.primary),
              tooltip: 'Change date',
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  List<MealType> _getAvailableMealTypes(
    OrderFormState state,
    AvailableOrderDays data,
  ) {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return [];

    final selectedDay = data.days
        .where(
          (day) => day.date == selectedDate,
        )
        .firstOrNull;

    if (selectedDay == null) return [];

    final availableTypes = <MealType>[];
    if (selectedDay.availableMealTypes.breakfast) {
      availableTypes.add(MealType.breakfast);
    }
    if (selectedDay.availableMealTypes.lunch) {
      availableTypes.add(MealType.lunch);
    }
    if (selectedDay.availableMealTypes.dinner) {
      availableTypes.add(MealType.dinner);
    }

    return availableTypes;
  }

  void _showSuccessDialog(BuildContext context, CreateOrderResponse order) {
    final bloc = context.read<OrderFormBloc>();

    // Show dialog after a brief delay to ensure proper rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh available days to reflect the new order
      bloc.add(const OrderFormLoadedEvent());

      // Get the next available date info
      final state = bloc.state;
      final nextAvailableInfo = _getNextAvailableDateInfo(state);

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

  ({String date, String label, bool canRepeat}) _getNextAvailableDateInfo(
    OrderFormState state,
  ) {
    final availableDays = state.availableDaysState.maybeMap(
      success: (s) => s.data.days,
      refreshing: (r) => r.currentData.days,
      orElse: () => <user_models.OrderDay>[],
    );

    // Find the next available date (not already ordered, not a holiday)
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    for (var i = 1; i <= 30; i++) {
      // Check up to 30 days ahead
      final checkDate = now.add(Duration(days: i));
      final dateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      user_models.OrderDay? day;
      try {
        day = availableDays.firstWhere((d) => d.date == dateStr);
      } catch (e) {
        day = null;
      }

      if (day != null &&
          day.isAvailable &&
          !day.alreadyOrdered &&
          day.holidayName == null) {
        // Found an available date
        final isTomorrow =
            checkDate.year == tomorrow.year &&
            checkDate.month == tomorrow.month &&
            checkDate.day == tomorrow.day;

        final label = isTomorrow
            ? 'Tomorrow'
            : DateFormat('MMM d').format(checkDate);

        return (
          date: dateStr,
          label: label,
          canRepeat: true, // Can repeat if date is available
        );
      }
    }

    // Fallback to tomorrow even if not available (will show banner)
    final tomorrowDate =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    return (
      date: tomorrowDate,
      label: 'Tomorrow',
      canRepeat: false, // Can't repeat if already ordered
    );
  }
}
