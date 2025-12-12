import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';
import 'package:homely_app/order_form/view/helpers/date_formatter.dart';
import 'package:homely_api/src/user/models/models.dart' as user_models;

/// Header showing the selected date with edit option
class SelectedDateHeaderWidget extends StatelessWidget {
  /// Constructor
  const SelectedDateHeaderWidget({
    required this.selectedDay,
    required this.selectedMealCount,
    super.key,
  });

  /// The selected day object (from API)
  final user_models.OrderDay selectedDay;

  /// Number of meals selected
  final int selectedMealCount;

  @override
  Widget build(BuildContext context) {
    // Use API-provided dayOfWeek where possible so weekday matches the
    // calendar chips (which read `dayOfWeek` from the API). Fall back to
    // computing the weekday from the ISO date if needed.
    final isoDate = selectedDay.date;
    final dayName = _formatDayNameFromApi(selectedDay.dayOfWeek, isoDate);
    final fullDate = OrderFormDateFormatter.formatFullOrderDate(isoDate);
    final formattedDate = '$dayName, $fullDate';

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
              onPressed: () => _handleDateChange(context),
              icon: const Icon(Icons.edit, color: AppColors.primary),
              tooltip: 'Change date',
            ),
          ],
        ),
      ),
    );
  }

  void _handleDateChange(BuildContext context) {
    if (selectedMealCount > 0) {
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
  }

  String _formatDayNameFromApi(String apiDay, String isoDate) {
    final s = apiDay.trim();
    if (s.isEmpty) {
      try {
        return OrderFormDateFormatter.getDayName(
          DateTime.parse(isoDate).weekday,
        );
      } catch (_) {
        return '';
      }
    }

    // API may send e.g. "MONDAY" or "Monday" - normalize to "Monday"
    final lower = s.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}
