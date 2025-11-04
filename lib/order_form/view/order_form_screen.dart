import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
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
      listener: (context, state) {
        // Handle order creation success
        state.createOrderState.maybeMap(
          success: (s) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order #${s.data.orderNumber} placed successfully!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // Navigate back or to orders list
            context.router.maybePop();
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
          appBar: AppBar(
            title: const Text('New Order'),
            elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CalendarSection(days: data.days),
          ),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildSelectedDateHeader(context, state),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
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
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dayName, $formattedDate',
                  style: context.textTheme.titleMedium?.copyWith(
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
}
