import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';

/// {@template final_order_confirmation_dialog}
/// Final confirmation dialog shown before submitting an order
/// Warns user that order cannot be modified or cancelled
/// {@endtemplate}
class FinalOrderConfirmationDialog extends StatelessWidget {
  /// {@macro final_order_confirmation_dialog}
  const FinalOrderConfirmationDialog({
    required this.state,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  /// Current order form state
  final OrderFormState state;

  /// Callback when user confirms order
  final VoidCallback onConfirm;

  /// Callback when user cancels
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.info_outline,
        color: AppColors.primary,
        size: 48,
      ),
      title: const Text('Confirm Your Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Meals:',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${state.selectedMealCount}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (state.selectedDate != null) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Date:',
                        style: context.textTheme.bodySmall,
                      ),
                      Text(
                        _formatDate(state.selectedDate!),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This order cannot be modified or cancelled once confirmed. For any changes, please contact customer support.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your order carefully before confirming.',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Confirm Order'),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
