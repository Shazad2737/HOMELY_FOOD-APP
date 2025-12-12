import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/src/user/models/models.dart' as user_models;
import 'package:intl/intl.dart';

/// {@template skipped_dates_warning_dialog}
/// Dialog that warns users when they select a date but have skipped
/// ordering on previous available dates
/// {@endtemplate}
class SkippedDatesWarningDialog extends StatelessWidget {
  /// {@macro skipped_dates_warning_dialog}
  const SkippedDatesWarningDialog({
    required this.skippedDates,
    required this.onProceed,
    required this.onCancel,
    super.key,
  });

  /// List of dates that were skipped (available but not ordered)
  final List<user_models.OrderDay> skippedDates;

  /// Callback when user chooses to proceed anyway
  final VoidCallback onProceed;

  /// Callback when user chooses to go back
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warning,
        size: 48,
      ),
      title: const Text('Skipped Dates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You haven't ordered for ${skippedDates.length} previous date${skippedDates.length == 1 ? '' : 's'}:",
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...skippedDates.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(day.date),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Do you want to proceed without ordering for these dates?',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Go Back'),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Proceed Anyway'),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('EEEE, MMM d').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}
