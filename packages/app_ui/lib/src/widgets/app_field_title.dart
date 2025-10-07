import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppFieldTitle extends StatelessWidget {
  const AppFieldTitle({
    required this.title,
    this.isRequired = true,
    super.key,
  });

  final String title;

  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
        ),
        if (isRequired) ...[
          const Space.half(),
          Text(
            '*',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}
