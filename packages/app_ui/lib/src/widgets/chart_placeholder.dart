import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template chart_placeholder}
/// A placeholder widget for charts that will be implemented later
/// {@endtemplate}
class ChartPlaceholder extends StatelessWidget {
  /// {@macro chart_placeholder}
  const ChartPlaceholder({
    required this.title,
    this.height = 200,
    this.subtitle,
    super.key,
  });

  /// The title of the chart
  final String title;

  /// Height of the placeholder
  final double height;

  /// Optional subtitle
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const Spacer(),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: AppColors.grey300,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chart Coming Soon',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
