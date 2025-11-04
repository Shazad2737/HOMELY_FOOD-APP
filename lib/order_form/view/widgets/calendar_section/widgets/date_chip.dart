import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_api/src/user/models/models.dart' as user_models;
import 'package:intl/intl.dart';

/// Individual date chip in the calendar
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
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
    // Selected state should be visually prominent: solid primary fill
    if (isSelected) {
      return AppColors.primary;
    }
    // Already ordered stays as solid success
    if (isOrdered) return AppColors.success;
    // Holidays (when not selected) should have white background with
    // a warning-colored border and warning text so they contrast with
    // the selected state.
    if (isHoliday) return AppColors.white;

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
    // Selected uses white text over primary
    if (isSelected) return AppColors.white;
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
