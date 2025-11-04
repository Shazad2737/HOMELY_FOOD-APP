import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template info_row}
/// Widget for displaying icon + text information rows
/// {@endtemplate}
class InfoRow extends StatelessWidget {
  /// {@macro info_row}
  const InfoRow({
    required this.icon,
    required this.text,
    super.key,
  });

  /// Icon to display
  final IconData icon;

  /// Text to display
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.appRed,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
