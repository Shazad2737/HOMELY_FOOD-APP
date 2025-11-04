import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/view/helpers/date_formatter.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/order_form_content/selected_date_header_widget.dart';
import 'package:instamess_app/order_form/view/widgets/widgets.dart';

/// Main content widget for order form
class OrderFormContentWidget extends StatelessWidget {
  /// Constructor
  const OrderFormContentWidget({
    required this.state,
    required this.data,
    super.key,
  });

  /// Current order form state
  final OrderFormState state;

  /// Available order days data
  final AvailableOrderDays data;

  @override
  Widget build(BuildContext context) {
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
              child: Builder(
                builder: (context) {
                  // Resolve the selected day object from the API data so the
                  // header uses the same source of truth (dayOfWeek, date)
                  final selectedDay = data.days
                      .where((day) => day.date == state.selectedDate)
                      .firstOrNull;

                  if (selectedDay == null) {
                    // Fallback: build header using the ISO date string (old behavior)
                    final date = DateTime.parse(state.selectedDate!);
                    final formattedDate =
                        OrderFormDateFormatter.formatSelectedDate(date);

                    return Row(
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
                                formattedDate,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => {},
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Change date',
                        ),
                      ],
                    );
                  }

                  return SelectedDateHeaderWidget(
                    selectedDay: selectedDay,
                    selectedMealCount: state.selectedMealCount,
                  );
                },
              ),
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

  List<MealType> _getAvailableMealTypes(
    OrderFormState state,
    AvailableOrderDays data,
  ) {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return [];

    final selectedDay = data.days
        .where((day) => day.date == selectedDate)
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
