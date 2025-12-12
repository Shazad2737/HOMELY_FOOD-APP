import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Day availability chip
class DayChip extends StatelessWidget {
  const DayChip({
    required this.label,
    required this.isAvailable,
    super.key,
  });

  final String label;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.appGreen : AppColors.grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: isAvailable ? AppColors.white : AppColors.grey500,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
