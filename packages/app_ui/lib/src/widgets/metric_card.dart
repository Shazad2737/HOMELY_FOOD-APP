import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template metric_card}
/// A card that displays a metric with title, value, and optional icon
/// {@endtemplate}
class MetricCard extends StatelessWidget {
  /// {@macro metric_card}
  const MetricCard({
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.subtitle,
    this.trend,
    this.onTap,
    super.key,
  });

  /// The title of the metric
  final String title;

  /// The value of the metric
  final String value;

  /// Optional icon to display
  final IconData? icon;

  /// Color for the icon
  final Color? iconColor;

  /// Color for the value text
  final Color? valueColor;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional trend indicator (e.g., "+12%" or "-5%")
  final String? trend;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
              if (subtitle != null || trend != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTrendColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTrendColor(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTrendColor() {
    if (trend == null) return AppColors.textSecondary;
    if (trend!.startsWith('+')) return AppColors.success;
    if (trend!.startsWith('-')) return AppColors.error;
    return AppColors.textSecondary;
  }
}
