import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_api/src/user/models/models.dart' as user_models;
import 'package:intl/intl.dart';

/// Calendar section with date chips
class CalendarSection extends StatelessWidget {
  /// Constructor
  const CalendarSection({
    required this.days,
    super.key,
  });

  /// List of available days
  final List<user_models.OrderDay> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Date',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              physics: const BouncingScrollPhysics(),
              cacheExtent: 500, // Cache 500 pixels ahead for smooth scrolling
              itemBuilder: (context, index) {
                return DateChip(
                  day: days[index],
                  key: ValueKey(days[index].date),
                );
              },
            ),
          ),
          if (days.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.swipe,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe to see more dates',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
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

/// Individual date chip
class DateChip extends StatelessWidget {
  /// Constructor
  const DateChip({
    required this.day,
    super.key,
  });

  /// The day data
  final user_models.OrderDay day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        final isSelected = state.selectedDate == day.date;
        final isHoliday = day.holidayName != null;
        final isOrdered = day.alreadyOrdered;
        final isDisabled = !day.isAvailable && !isHoliday && !isOrdered;

        return GestureDetector(
          onTap: () {
            if (isHoliday || isOrdered) {
              // Just select it to show the banner
              if (state.selectedMealCount > 0 && state.selectedDate != null) {
                _showChangeDateDialog(context);
              } else {
                context.read<OrderFormBloc>().add(
                  OrderFormDateSelectedEvent(day.date),
                );
              }
              return;
            }

            if (isDisabled) return;

            // Check if user has already selected meals
            if (state.selectedMealCount > 0 && state.selectedDate != null) {
              _showChangeDateDialog(context);
            } else {
              context.read<OrderFormBloc>().add(
                OrderFormDateSelectedEvent(day.date),
              );
            }
          },
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: _getBackgroundColor(
                isSelected,
                isHoliday,
                isOrdered,
                isDisabled,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(
                  isSelected,
                  isHoliday,
                  isOrdered,
                  isDisabled,
                ),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day of week
                Text(
                  _formatDayOfWeek(day.dayOfWeek),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: _getTextColor(
                      isSelected,
                      isDisabled,
                      isHoliday,
                      isOrdered,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                // const SizedBox(height: 4),
                // Date number
                Text(
                  _formatDate(day.date),
                  style: context.textTheme.titleLarge?.copyWith(
                    color: _getTextColor(
                      isSelected,
                      isDisabled,
                      isHoliday,
                      isOrdered,
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                // Status indicator (icon below date)
                if (isOrdered || isHoliday) ...[
                  const SizedBox(height: 2),
                  Icon(
                    isOrdered ? Icons.check_circle : Icons.celebration,
                    size: 12,
                    color: _getTextColor(
                      isSelected,
                      isDisabled,
                      isHoliday,
                      isOrdered,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(
    bool isSelected,
    bool isHoliday,
    bool isOrdered,
    bool isDisabled,
  ) {
    if (isDisabled) return AppColors.grey200;
    if (isSelected)
      return AppColors.primary.withValues(
        alpha: 0.1,
      );
    if (isOrdered) return AppColors.success;
    if (isHoliday) return AppColors.warning.withValues(alpha: 0.2);
    return AppColors.white;
  }

  Color _getBorderColor(
    bool isSelected,
    bool isHoliday,
    bool isOrdered,
    bool isDisabled,
  ) {
    if (isDisabled) return AppColors.grey300;
    if (isSelected) return AppColors.primary;
    if (isOrdered) return AppColors.success;
    if (isHoliday) return AppColors.warning;
    return AppColors.grey300;
  }

  Color _getTextColor(
    bool isSelected,
    bool isDisabled,
    bool isHoliday,
    bool isOrdered,
  ) {
    if (isDisabled) return AppColors.grey500;
    if (isSelected) return AppColors.black;
    if (isOrdered) return AppColors.white;
    if (isHoliday) return AppColors.warning;
    return AppColors.textPrimary;
  }

  String _formatDayOfWeek(String dayOfWeek) {
    return dayOfWeek.substring(0, 3);
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('d').format(dateTime);
  }

  void _showChangeDateDialog(BuildContext context) {
    // Capture the bloc and day reference before the dialog
    final bloc = context.read<OrderFormBloc>();
    final targetDate = day.date;

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
            child: Text(
              'Cancel',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // First clear the selections, then select the new date
              bloc
                ..add(const OrderFormDateClearedEvent())
                ..add(OrderFormDateSelectedEvent(targetDate));
            },
            child: Text(
              'Change Date',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.appRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
