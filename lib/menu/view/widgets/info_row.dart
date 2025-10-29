import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Info row with icon and text
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.text,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.grey500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }
}
