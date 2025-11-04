import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template empty_state}
/// Widget displayed when there are no orders
/// {@endtemplate}
class EmptyState extends StatelessWidget {
  /// {@macro empty_state}
  const EmptyState({required this.message, super.key});

  /// Message to display
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
